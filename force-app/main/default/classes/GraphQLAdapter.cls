/**
 * Valence (https://valence.app) Adapter that can interact with a GraphQL endpoint over HTTP.
 */
global with sharing class GraphQLAdapter implements valence.NamedCredentialAdapter, valence.ConfigurableSourceAdapter, valence.LazyLoadSchemaAdapter, valence.SourceAdapterScopeSerializer {

	/** The expected datetime formatting that the API needs for Datetime literals (ISO 8601) */
	public final static String API_DATETIME_FORMAT = 'yyyy-MM-dd\'T\'HH:mm:ss\'Z\'';

	@TestVisible
	private String namedCredential;

	// temporary token for API access, only saved for the duration of this execution context
	@TestVisible
	private String accessToken = null;

	// set during planFetch() if we are interacting with an endpoint that implements the Pageable interface
	@TestVisible
	private Boolean currentInnerTypeIsPageable = false;

	// source configuration
	@TestVisible
	private SourceConfiguration sourceConfig = null;

	// special variable only used in test coverage to help identify which callout we're on, when multiple callouts are involved in a single test
	@TestVisible
	private Integer testCalloutNumber = 1;

	// ----------------------------------
	// ----- NamedCredentialAdapter -----
	// ----------------------------------

	/**
	 * Here we are handed a NamedCredential to use by the Valence framework.
	 *
	 * @param namedCredential The NamedCredential name that we will use to connect to the API
	 */
	public void setNamedCredential(String namedCredential) {
		this.namedCredential = namedCredential;
	}

	// -------------------------
	// ----- SchemaAdapter -----
	// -------------------------

	/**
	 * Valence framework asking us to describe what tables are available for retrieval from our API.
	 *
	 * @return A list of tables we can read from
	 */
	public List<valence.Table> getTables() {

		List<valence.Table> tables = new List<valence.Table>();

		/*
		 * We use GraphQLs built-in introspection to request a list of Queries that can be called, and then a list of Mutations.
		 */
		HttpRequest req = buildRequest();
		req.setBody(JSON.serialize(new GraphQLQuery(buildQueryTypeNode(), null)));

		for(valence.JSONParse resource : callAndParse(req).get('data.__schema.queryType.fields').asList()) {
			tables.add(
				valence.Table.create(resource.get('name').getStringValue())
					.withDescription(resource.get('description').getStringValue())
					.build()
			);
		}

		req = buildRequest();
		req.setBody(JSON.serialize(new GraphQLQuery(buildMutationTypeNode(), null)));

		for(valence.JSONParse resource : callAndParse(req).get('data.__schema.mutationType.fields').asList()) {
			tables.add(
				valence.Table.create(resource.get('name').getStringValue())
					.withDescription(resource.get('description').getStringValue())
					.setEditable(true)
					.setReadable(false)
					.build()
			);
		}

		return tables;
	}

	/**
	 * Valence framework asking for field-level information to understand the shape of what can be retrieved.
	 *
	 * @param tableName The specific table we want to get field information for
	 *
	 * @return A list of fields that can be retrieved on the given table
	 */
	public List<valence.Field> getFields(String tableName) {

		List<valence.Field> fields = new List<valence.Field>();

		// retrieve the "primary" type for a Query, which is the main OBJECT type after we strip away wrapper types and pagination types
		valence.JSONParse primaryType = fetchPrimaryType(tableName);

		// build a Valence Field representation of each one
		for(valence.JSONParse fieldDef : primaryType.get('fields').asList()) {
			fields.add(parseField(fieldDef));
		}

		return fields;
	}

	// ---------------------------------
	// ----- LazyLoadSchemaAdapter -----
	// ---------------------------------

	public List<valence.Field> getLazyFieldChildren(String tableName, valence.FieldPath path) {
		return getLazyFieldChildren(tableName, path.getSequence());
	}

	@TestVisible
	private List<valence.Field> getLazyFieldChildren(String tableName, List<valence.Field> path) {

		System.debug(LoggingLevel.WARN, 'getLazyFieldChildren(' + tableName + ')');
		System.debug(LoggingLevel.WARN, path);

		List<valence.Field> fields = new List<valence.Field>();

		// retrieve the "primary" type for a Query, which is the main OBJECT type after we strip away wrapper types and pagination types
		valence.JSONParse type = fetchPrimaryType(tableName);

		// drill down through the sequence, retrieving field lists until we hit the end
		while(!path.isEmpty()) {
			String fieldName = path.remove(0).name;
			// find the field that matches this part of the path
			for(valence.JSONParse fieldDef : type.get('fields').asList()) {
				if(fieldName.equalsIgnoreCase(fieldDef.get('name').getStringValue())) {
					System.debug(LoggingLevel.WARN, 'Matched <' + fieldName + '> to ' + fieldDef);
					// hit the API again and grab a __Type definition for the field we just matched on
					valence.JSONParse extract = extractInnerType(fieldDef.get('type'));
					System.debug(LoggingLevel.WARN, 'Extracted primary type(' + extract.get('name').getStringValue() + '): ' + extract.toStringPretty());
					HttpRequest req = buildRequest();
					req.setBody(JSON.serialize(new GraphQLQuery(buildFullTypeNode(true), new Map<String, String>{'typeName' => extract.get('name').getStringValue()})));
					type = callAndParse(req).get('data.__type');
					break;
				}
			}
		}

		// build a Valence Field representation of each field
		for(valence.JSONParse fieldDef : type.get('fields').asList()) {
			fields.add(parseField(fieldDef));
		}

		return fields;
	}


	// ----------------------------------------
	// ----- SourceAdapterScopeSerializer -----
	// ----------------------------------------

	/**
	 * Tell Valence how to go about retrieving records from this Adapter.
	 *
	 * @param context Details about this Link run
	 *
	 * @return The strategy to use when fetching records from this Adapter's endpoint
	 */
	public valence.FetchStrategy planFetch(valence.LinkContext context) {

		// get information about the corresponding Query
		valence.JSONParse queryType = fetchQueryType(context.linkSourceName);

		// use that query response to extract information about the inner type for this query (inside NON_NULL and LIST wrappers)
		valence.JSONParse innerType = extractInnerType(queryType.get('type'));
		System.debug(LoggingLevel.WARN, 'innerType:' + innerType.toStringPretty());

		// inspect the result to check to see if we can paginate these records or not
		currentInnerTypeIsPageable = false;
		for(valence.JSONParse interfaceDef : innerType.get('interfaces').asList()) {
			if('Pageable'.equalsIgnoreCase(interfaceDef.get('name').getStringValue())) {
				currentInnerTypeIsPageable = true;
				break;
			}
		}

		System.debug(LoggingLevel.WARN, 'innerTypeIsPageable:' + currentInnerTypeIsPageable);

		if(currentInnerTypeIsPageable == false) {

			System.debug(LoggingLevel.WARN, 'planFetch: immediate because not pageable');
			// if we can't paginate, just go ahead and fetch the data
			return valence.FetchStrategy.immediate();
		}
		else {

			// call the API to get a single record so we can figure out how to do our batches
			HttpRequest req = buildRequest();
			req.setBody(JSON.serialize(buildRecordQuery(context, 1, 0)));
			valence.JSONParse pagination = callAndParse(req).get('data.' + context.linkSourceName + '.pagination');
			Long total = pagination.get('total').getIntegerValue();
			Integer pageSize = context.batchSizeLimit > 100 ? 100 : context.batchSizeLimit; // API has a max page size of 100

			if(total == 0) {
				System.debug(LoggingLevel.WARN, 'planFetch: no records');
				return valence.FetchStrategy.noRecords();
			}
			else if(total < pageSize) {
				System.debug(LoggingLevel.WARN, 'planFetch: immediate because fewer records (' + total + ') than batch size (' + pageSize + ')');
				return valence.FetchStrategy.immediate(total);
			}
			else {
				List<FetchScope> scopes = new List<FetchScope>();
				Integer offset = 0;
				while(offset <= total) {
					scopes.add(new FetchScope(pageSize, offset));
					offset += pageSize;
				}
				System.debug(LoggingLevel.WARN, 'planFetch: scopes with (' + scopes.size() + ') scopes to fetch (' + total + ') total records.');
				return valence.FetchStrategy.scopes(scopes, total);
			}
		}
	}

	/**
	 * Called by Valence framework to retrieve a batch of records from the target endpoint.
	 *
	 * @param context Details about this Link run
	 * @param scope Specific details about the current scope
	 *
	 * @return A batch of records
	 */
	public List<valence.RecordInFlight> fetchRecords(valence.LinkContext context, Object scope) {

		List<valence.RecordInFlight> records = new List<valence.RecordInFlight>();

		Integer pageSize = scope != null ? ((FetchScope)scope).pageSize : null;
		Integer offset = scope != null ? ((FetchScope)scope).offset : null;

		if(currentInnerTypeIsPageable == true) { // only true for pageable "immediate" runs, ensures "pageable" behavior during "immediate" runs
			pageSize = context.batchSizeLimit > 100 ? 100 : context.batchSizeLimit; // API has a max page size of 100
			offset = 0;
		}

		// call the API to fetch records
		HttpRequest req = buildRequest();
		req.setBody(JSON.serializePretty(buildRecordQuery(context, pageSize, offset)));

		// extract the list of records (either or from inside pagination, depending on if this endpoint uses pagination)
		valence.JSONParse response = callAndParse(req);

		/*
		 * Check for record-level errors, and if any are found, build up a representation we can use to match them to records. Since
		 * we don't know if multiple errors can be thrown for the same record, we aggregate by row number.
		 */
		Map<Integer, List<String>> errorsByRow = new Map<Integer, List<String>>();
		if(response.exists('errors')) {

			// iterate through the errors and transform each one into something usable
			for(valence.JSONParse error : response.get('errors').asList()) {

				// extract a row number from this error
				Integer rowNumber = null;
				if(error.exists('path')) {
					List<Object> path = (List<Object>)error.get('path').getValue();
					for(Object pathPart : path) {
						// we take the first integer we find; any deeper part of the path is irrelevant since we have one list of RecordInFlight instances
						if(pathPart instanceof Integer) {
							rowNumber = (Integer)pathPart;
							break;
						}
					}
				}

				// if rowNumber was found
				if(rowNumber != null) {
					// start a list if empty
					if(!errorsByRow.containsKey(rowNumber)) {
						errorsByRow.put(rowNumber, new List<String>());
					}
					// add this error
					errorsByRow.get(rowNumber).add(extractErrorMessage(error));
				}
			}
		}

		List<valence.JSONParse> recordList = response.get('data.' + context.linkSourceName + (pageSize != null && offset != null ? '.pages' : '')).asList();

		for(Integer i = 0, j = recordList.size(); i < j; i++) {

			valence.RecordInFlight record = new valence.RecordInFlight((Map<String, Object>)recordList[i].getValue());

			// check for record-level errors, and if found, add them to the record
			if(errorsByRow.containsKey(i)) {
				for(String errorMessage : errorsByRow.get(i)) {
					record.addError(errorMessage);
				}
			}

			records.add(record);
		}

		return records;
	}

	public Object deserializeScope(String serializedScope) {
		return JSON.deserialize(serializedScope, FetchScope.class);
	}

	public String serializeScope(Object scope) {
		return JSON.serialize(scope);
	}

	// -------------------------------------
	// ----- ConfigurableSourceAdapter -----
	// -------------------------------------

	public String explainSourceConfiguration(valence.LinkContext context, String configData) {
		SourceConfiguration config = new SourceConfiguration(configData);
		if(config.arguments.isEmpty()) {
			return 'No additional parameters are configured.';
		}
		else {
			return 'There are (' + config.arguments.size() + ') parameters that will be added to GraphQL queries.';
		}
	}

	public String getSourceConfigurationLightningComponent(valence.LinkContext context) {
		return 'c:graphQLAdapterSourceConfigurator';
	}

	public String getSourceConfigurationStructure(valence.LinkContext context) {
		return null;
	}

	public void setSourceConfiguration(valence.LinkContext context, String configData) {
		sourceConfig = new SourceConfiguration(configData);
	}

	// -------------------
	// ----- HELPERS -----
	// -------------------

	private valence.JSONParse callAndParse(HttpRequest req) {

		System.debug(LoggingLevel.WARN, req.getBody());

		// send the request
		HttpResponse res = new Http().send(req);

		System.debug(LoggingLevel.WARN, res.getBody());

		// check for errors
		checkForErrors(res, req.getEndpoint());

		valence.JSONParse payload = new valence.JSONParse(res.getBody());
		checkForErrors(payload);

		// return a response
		return payload;
	}

	/**
	 * Check for errors at the transport layer of an HTTP response.
	 *
	 * @param response The API response to inspect for errors
	 * @param url The url that was being accessed
	 * @throws AdapterException if errors are encountered
	 */
	private void checkForErrors(HttpResponse response, String url) {
		if(response.getStatusCode() >= 200 && response.getStatusCode() < 300) {
			return;
		}

		throw new valence.AdapterException(response.getStatusCode() + ':' + response.getStatus() + ':' + response.getBody());
	}

	/**
	 * Check for errors in the body of an HTTP response.
	 *
	 * @param response The parsed API response
	 * @throws AdapterException if errors are encountered
	 */
	private void checkForErrors(valence.JSONParse response) {

		/*
		 * If there were errors and no data, throw an exception immediately.
		 *
		 * If there was data, we assume the errors are per-record and merge them with the records elsewhere.
		 */
		if(!response.exists('data', true) && response.exists('errors', true)) {
			Set<String> messages = new Set<String>();

			for(valence.JSONParse error : response.get('errors').asList()) {
				messages.add(extractErrorMessage(error));
			}

			List<String> messageList = new List<String>(messages);
			messageList.sort();
			throw new valence.AdapterException('API Errors: ' + String.join(messageList, ' '));
		}
	}

	private String extractErrorMessage(valence.JSONParse apiError) {
		List<String> errorParts = new List<String>();
		if(apiError.exists('extensions.code', true)) {
			errorParts.add(apiError.get('extensions.code').getStringValue());
		}
		if(apiError.exists('message', true)) {
			errorParts.add(apiError.get('message').getStringValue());
		}
		if(apiError.exists('extensions.details', true)) {
			errorParts.add(apiError.get('extensions.details').getStringValue());
		}
		return String.join(errorParts, ':');
	}

	private HttpRequest buildRequest() {

		if(accessToken == null) {
			fetchAccessToken();
		}

		HttpRequest req = buildBasicRequest();
		req.setHeader('Authorization', 'Bearer ' + accessToken);
		req.setEndpoint('callout:' + namedCredential);

		return req;
	}

	/**
	 * Go generate an access token to use during this session.
	 */
	@TestVisible
	private void fetchAccessToken() {

		HttpRequest req = buildBasicRequest();
		req.setEndpoint('callout:' + namedCredential + '/token');
		req.setBody('{"clientId":"{!$Credential.Username}","clientSecret":"{!$Credential.Password}","grantType":"client_credentials"}');

		// send the request
		HttpResponse res = new Http().send(req);

		// check http headers for errors
		checkForErrors(res, req.getEndpoint());

		// check body for errors
		valence.JSONParse payload = new valence.JSONParse(res.getBody());
		checkForErrors(payload);

		// set the access token
		accessToken = payload.get('accessToken').getStringValue();
	}

	/**
	 * @return Our simplest, bare-bones HTTPRequest instance
	 */
	private HttpRequest buildBasicRequest() {

		HttpRequest req = new HttpRequest();
		req.setEndpoint('callout:' + namedCredential + '/token');
		req.setMethod('POST');
		req.setHeader('Content-Type', 'application/json');
		req.setHeader('Accept', 'application/json');
		req.setHeader('Accept-Encoding', 'gzip');
		req.setTimeout(120000);

		// special helper value when we are making multiple callouts in a single apex test
		if(Test.isRunningTest()) {
			req.setHeader('Callout-Number', String.valueOf(testCalloutNumber));
			testCalloutNumber++;
		}

		return req;
	}

	/**
	 * GraphQL "Queries" are the main entry point for fetching data, and are actually represented in GraphQL's schema as "field" instances on the Query type
	 * (one field instance for each query that is available).
	 *
	 * Often, we are only interested in learning about one query, so this method allows you to name the query you are interested in getting details about.
	 *
	 * @param queryName The name of the GraphQL query we want to get a __Type definition for.
	 *
	 * @return A __Type definition for this particular Query
	 */
	private valence.JSONParse fetchQueryType(String queryName) {

		/*
		 * We use GraphQLs built-in introspection to request a list of Queries that can be called, and then we drill into the query we care about.
		 *
		 * We have to do this because there's no way in GraphQL to fetch a single query's schema as a standalone request.
		 */
		HttpRequest req = buildRequest();
		req.setBody(JSON.serialize(new GraphQLQuery(buildQueryTypeNode(), null)));

		for(valence.JSONParse resource : callAndParse(req).get('data.__schema.queryType.fields').asList()) {

			// find the query name that matches the parameter we were given
			if(queryName.equals(resource.get('name').getStringValue())) {
				return resource;
			}
		}

		throw new valence.AdapterException('Could not locate a GraphQL query matching <' + queryName + '>.');
	}

	/**
	 * GraphQL schemas are inherently quite nested. A Type that we would consider the "primary" flavor of data a query is about might be nested several layers
	 * deep, wrapped inside other GraphQL types like "NON_NULL" and "LIST". Furthermore, if we are paginating and have metadata our primary type could be even
	 * further from the top layer.
	 *
	 * This method fetches the schema definition a specific GraphQL Type and then drills down (possibly fetching more data) until it is satisfied that it has
	 * located the "primary" Type this query is built around.
	 *
	 * @param queryName The name of the GraphQL query we want to get the "primary" __Type definition for.
	 *
	 * @return A _Type definition for the inner Type that we would consider to be the "primary" Type that this query is all about
	 */
	private valence.JSONParse fetchPrimaryType(String queryName) {

		// get information about the corresponding Query
		valence.JSONParse queryType = fetchQueryType(queryName);

		// use that query response to extract information about the primary type for this query
		valence.JSONParse primaryType = extractInnerType(queryType.get('type'));
		System.debug(LoggingLevel.WARN, 'innerType:' + primaryType.toStringPretty());

		// call the API again to get the full representation of this primary type (the one inside the Query response just has type info, no fields/interfaces/etc)
		HttpRequest req = buildRequest();
		req.setBody(JSON.serialize(new GraphQLQuery(buildFullTypeNode(true), new Map<String, String>{'typeName' => primaryType.get('name').getStringValue()})));
		primaryType = callAndParse(req).get('data.__type');

		// drill down an extra layer if this is a type that implements the bespoke "Pageable" interface, which we hide from users
		for(valence.JSONParse interfaceDef : primaryType.get('interfaces').asList()) {
			if('Pageable'.equalsIgnoreCase(interfaceDef.get('name').getStringValue())) {
				for(valence.JSONParse fieldDef : primaryType.get('fields').asList()) {
					if('pages'.equalsIgnoreCase(fieldDef.get('name').getStringValue())) {
						primaryType = extractInnerType(fieldDef.get('type'));
						System.debug(LoggingLevel.WARN, 'pagedType:' + primaryType.toStringPretty());
						break;
					}
				}
				break;
			}
		}

		return primaryType;
	}

	/**
	 * Since GraphQL nests types inside wrapper types like NON_NULL and LIST, we often want to find out what is the "inner" type that is underneath all those
	 * wrappers. This method drills into a Type and figures out what it is really about.
	 *
	 * @param typeDef A JSON representation of a GraphQL __Type
	 *
	 * @return The main __Type that is somewhere inside the passed __Type
	 */
	private valence.JSONParse extractInnerType(valence.JSONParse typeDef) {

		String typeKind = typeDef.get('kind').getStringValue();
		while('NON_NULL'.equals(typeKind) || 'LIST'.equals(typeKind)) {
			typeDef = typeDef.get('ofType');
			typeKind = typeDef.get('kind').getStringValue();
		}

		return typeDef;
	}

	private valence.Field parseField(valence.JSONParse fieldNode) {
		valence.Field.FieldBuilder builder = valence.Field.create(fieldNode.get('name').getStringValue()).setEditable(false).setRequired(false);
		builder.withDescription(fieldNode.get('description').getStringValue());
		applyType(builder, fieldNode.get('type'), false, false);
		return builder.build();
	}

	/**
	 * Inspect a nested chain of __Type definitions and merge information about them into a Field definition for Valence.
	 *
	 * @param builder An in-progress Valence FieldBuilder that we're going to further modify.
	 * @param type JSON representation of a GraphQL "__Type" for a field
	 * @param isList true if we have already figured out this field is a List
	 * @param skipNonNull true if we don't care about seeing the NON_NULL wrapper class anymore (we only care about a top-level one)
	 */
	private void applyType(valence.Field.FieldBuilder builder, valence.JSONParse type, Boolean isList, Boolean skipNonNull) {

		switch on type.get('kind').getStringValue() {
			when 'NON_NULL' {
				if(skipNonNull == false) {
					builder.setRequired(true);
				}
				applyType(builder, type.get('ofType'), isList, true);
			}

			when 'LIST' {
				builder.setList(true, true);
				applyType(builder, type.get('ofType'), true, true);
			}

			when 'OBJECT' {
				builder.setMap(true, true);
				builder.withType(isList == true ? 'LIST<' + type.get('name').getStringValue() + '>' : type.get('name').getStringValue());
			}

			when else {
				builder.withType(isList == true ? 'LIST<' + type.get('name').getStringValue() + '>' : type.get('name').getStringValue());
			}
		}
	}

	private GraphQLNode buildQueryTypeNode() {
		return buildSchemaTypeNode('queryType');
	}

	private GraphQLNode buildMutationTypeNode() {
		return buildSchemaTypeNode('mutationType');
	}

	private GraphQLNode buildSchemaTypeNode(String type) {

		return new GraphQLNode('__schema')
			.add(
				typeScalars()
					.setId(type)
					.add(
					new GraphQLNode('fields')
						.add('name')
						.add('description')
						.add(argChainDetails())
						.add(typeChainDetails())
				)
			);
	}

	private GraphQLNode buildFullTypeNode(Boolean includeFields) {

		GraphQLNode typeNode = typeScalars()
			.setId('__type')
			.addArguments(new GraphQLArgument('name', '$typeName', true))
			.add(typeScalars().setId('interfaces'));
		if(includeFields == true) {
			typeNode.add(fieldsScalars().add(typeChainDetailsWithFields()));
		}

		return new GraphQLNode('FetchType')
			.setOperation('query')
			.addArguments(new GraphQLArgument('$typeName', 'String!', true))
			.add(typeNode);
	}

	private GraphQLNode argChainDetails() {
		return new GraphQLNode('args')
			.add('name')
			.add('description')
			.add('defaultValue')
			.add(typeChainDetails());
	}

	private GraphQLNode typeChainDetails() {

		/*
		 * GraphQL nests types inside other types (such as NON_NULL and LIST), so we want to make sure we inquire with enough depth to get that full chain.
		 */
		GraphQLNode ofTypeTree = typeScalars().setId('ofType');
		for(Integer i = 0, j = 4; i < j; i++) {
			ofTypeTree = typeScalars().setId('ofType').add(ofTypeTree);
		}

		return typeScalars().add(ofTypeTree);
	}

	private GraphQLNode typeScalars() {
		return new GraphQLNode('type')
			.add('name')
			.add('kind')
			.add('description')
			.add(
				new GraphQLNode('enumValues')
					.add('name')
			)
			.add(
				new GraphQLNode('interfaces')
					.add('name')
					.add('kind')
					.add('description')
			);
	}

	private GraphQLNode fieldsScalars() {
		return new GraphQLNode('fields')
			.add('name')
			.add('description');
	}

	private GraphQLNode typeChainDetailsWithFields() {

		/*
		 * GraphQL nests types inside other types (such as NON_NULL and LIST), so we want to make sure we inquire with enough depth to get that full chain.
		 */
		GraphQLNode ofTypeTree = typeScalars().setId('ofType').add(fieldsScalars().add(typeChainDetails()));
		for(Integer i = 0, j = 4; i < j; i++) {
			ofTypeTree = typeScalars().setId('ofType').add(fieldsScalars().add(typeChainDetails())).add(ofTypeTree);
		}

		return typeScalars().add(ofTypeTree);
	}

	/**
	 * Given details about the running Link and some scope details, construct the correct GraphQL query to extract records from the API.
	 *
	 * @param context Details about the running Link
	 * @param pageSize How many records to fetch, or null if this endpoint doesn't support pagination
	 * @param offset How deep into the resultset to go, or null if this endpoint doesn't support pagination
	 *
	 * @return A GraphQL ready to be sent to the API
	 */
	private GraphQLQuery buildRecordQuery(valence.LinkContext context, Integer pageSize, Integer offset) {

		// turn a flat list of mappings into a tree
		Map<String, Object> mappingTree = new Map<String, Object>();
		for(valence.Mapping mapping : context.mappings.values()) {

			Map<String, Object> pointer = mappingTree; // helps us recurse down into the tree
			for(valence.Field field : mapping.sourceFieldPath.getSequence()) { // iterate through the source path chain and drill into our map one layer for each field
				if(!pointer.containsKey(field.name)) {
					pointer.put(field.name, new Map<String, Object>());
				}
				pointer = (Map<String, Object>)pointer.get(field.name);
			}
		}

		// turn that tree into nested GraphQLNode instances
		GraphQLNode shape = new GraphQLNode(context.linkSourceName);
		addDescendants(shape, mappingTree);

		// if this scope has pagination details then this endpoint supports pagination, add appropriate wrapping and metadata
		if(pageSize != null && offset != null) {
			// rename the shape and wrap it
			shape.id = 'pages';
			shape = new GraphQLNode(context.linkSourceName)
				.add(shape)
				.add(
					new GraphQLNode('pagination')
						.add('items')
						.add('total')
						.add('next')
						.add('previous')
				);
			// paginate the request
			shape.addArguments(
				new GraphQLArgument('limit', new List<GraphQLArgument>{
					new GraphQLArgument('take', pageSize),
					new GraphQLArgument('skip', offset)
				})
			);
		}

		// the "users" endpoint supports filtering on last modified date
		if('users'.equalsIgnoreCase(context.linkSourceName) && context.lastSuccessfulSync != null) {
			shape.addArguments(new GraphQLArgument('lastModifiedSinceDate', context.lastSuccessfulSync.formatGmt(API_DATETIME_FORMAT)));
		}

		// set variables on the payload type and wrap it in a query node
		GraphQLNode queryNode = new GraphQLNode('recordFetch').add(shape).setOperation('query');
		Map<String, Object> variables = new Map<String, Object>();
		for(Argument arg : sourceConfig.arguments) {
			queryNode.addArguments(new GraphQLArgument('$' + arg.name, arg.fullType, true)); // define variable on top-level query
			shape.addArguments(new GraphQLArgument(arg.name, '$' + arg.name, true)); // define variable usage on inner payload node
			variables.put(arg.name, arg.value);
		}

		System.debug(LoggingLevel.WARN, '***** QUERY *****\n' + queryNode.build());
		return new GraphQLQuery(queryNode, variables);
	}

	/**
	 * Recursively build out a tree of GraphQLNodes mixed with non-GraphQLNodes as needed.
	 *
	 * @param node The starting node
	 * @param children Potential children for it, with nested structure
	 */
	private void addDescendants(GraphQLNode node, Map<String, Object> children) {

		for(String name : children.keySet()) {
			Map<String, Object> childrenOfChild = (Map<String, Object>)children.get(name);
			if(childrenOfChild.isEmpty()) {
				node.add(name);
			}
			else {
				GraphQLNode childNode = new GraphQLNode(name);
				addDescendants(childNode, childrenOfChild);
				node.add(childNode);
			}
		}
	}

	/**
	 * Fetches argument details for a GraphQL query that a particular Link fetches data from. This method supports our configuration UI where Users can browse
	 * and configure custom arguments that will be passed to the adapter when it is fetching live data.
	 *
	 * @param linkName The link to check arguments on
	 *
	 * @return A representation of the arguments that can be passed to the GraphQL query this Link fetches from
	 */
	@AuraEnabled
	public static List<Argument> fetchQueryArgumentDefinitions(String linkName) {

		GraphQLAdapter adapter = new GraphQLAdapter();

		String credentials, typeName;
		if(Test.isRunningTest()) {
			credentials = 'fetchArguments';
			typeName = 'accounts';
		} else {
			// query the Link table so we can find out some key details, like the right NamedCredential to use to check the schema
			valence__ValenceDataLink__mdt link = [SELECT valence__SourceName__c, valence__SourceNamedCredentialName__c FROM valence__ValenceDataLink__mdt WHERE QualifiedApiName = :linkName];
			credentials = link.valence__SourceNamedCredentialName__c;
			typeName = link.valence__SourceName__c;
		}

		adapter.setNamedCredential(credentials);
		valence.JSONParse queryType = adapter.fetchQueryType(typeName);

		List<Argument> arguments = new List<Argument>();
		for(valence.JSONParse argData : queryType.get('args').asList()) {

			Argument arg = new Argument();
			arg.name = argData.get('name').getStringValue();
			applyType(arg, argData.get('type'));
			if(arg.simpleType == null) { // skip this definition if we didn't calculate a type (usually because of INPUT_OBJECT)
				continue;
			}
			// calculate the "full" representation of type, something like "[Boolean!]!" or "String!"
			arg.fullType = String.format('{0}{1}{2}{3}{4}', new List<Object>{
				arg.isList == true ? '[' : '',
				arg.simpleType,
				arg.areItemsRequired == true ? '!' : '',
				arg.isList == true ? ']' : '',
				arg.isRequired == true ? '!' : ''
			});

			arg.defaultValue = argData.get('defaultValue').getStringValue();

			arguments.add(arg);
		}
		return arguments;
	}

	/**
	 * Inspect a nested chain of __Type definitions and merge information about them into an Argument representation for our frontend.
	 *
	 * @param argument An in-progress Argument instance that we're going to further modify.
	 * @param type JSON representation of a GraphQL "__Type" for a field
	 */
	private static void applyType(Argument argument, valence.JSONParse type) {

		switch on type.get('kind').getStringValue() {
			when 'NON_NULL' {
				if(argument.isList == true) { // if we already saw LIST
					argument.areItemsRequired = true;
				}
				else {
					argument.isRequired = true;
				}
				applyType(argument, type.get('ofType'));
			}

			when 'LIST' {
				argument.isList = true;
				applyType(argument, type.get('ofType'));
			}

			when 'INPUT_OBJECT' {
				// do nothing
			}

			when 'ENUM' {
				argument.isEnum = true;
				argument.enumValues = new List<String>();
				for(valence.JSONParse enumValue : type.get('enumValues').asList()) {
					argument.enumValues.add(enumValue.get('name').getStringValue());
				}
				argument.simpleType = type.get('name').getStringValue();
			}

			when else {
				argument.simpleType = type.get('name').getStringValue();
			}
		}
	}

	@TestVisible
	private class SourceConfiguration {

		@TestVisible
		private List<Argument> arguments;

		SourceConfiguration(String jsonData) {
			arguments = new List<Argument>();

			if(String.isBlank(jsonData)) {
				return;
			}
			valence.JSONParse parse = new valence.JSONParse(jsonData);
			if(parse.exists('arguments')) {
				for(valence.JSONParse argData : parse.get('arguments').asList()) {
					Argument arg = new Argument();
					arg.name = argData.get('name').getStringValue();
					arg.fullType = argData.get('fullType').getStringValue();
					arg.value = argData.get('value').getValue();
					arguments.add(arg);
				}
			}
		}
	}

	/**
	 * A convenience class that helps us talk about GraphQL arguments. It defines both the shape of what an argument looks like and the value that will be passed.
	 *
	 * We serve instances of these to the configurator UI so it can help users pick values, and the serialized configuration we work with during Link runs contains
	 * instances of these as well.
	 *
	 * Not all properties are set in both usages, see comments below.
	 */
	@TestVisible
	private class Argument {

		// used in both configuration and UI
		@AuraEnabled public String name;
		@AuraEnabled public String fullType;

		// used in configuration only
		@TestVisible
		private Object value;

		// used in UI only
		@AuraEnabled public String simpleType;
		@AuraEnabled public Boolean isList = false;
		@AuraEnabled public Boolean isRequired = false;
		@AuraEnabled public Boolean areItemsRequired = false; // if isList = true, do individual items in the array have to be NON_NULL
		@AuraEnabled public Boolean isEnum = false;
		@AuraEnabled public List<String> enumValues = null;
		@AuraEnabled public String defaultValue;
	}

	/**
	 * Small container class to hold scope information about a single page of data we are fetching from the GraphQL API.
	 */
	@TestVisible
	private class FetchScope {

		@TestVisible
		private Integer pageSize;
		@TestVisible
		private Integer offset;

		@TestVisible
		private FetchScope(Integer pageSize, Integer offset) {
			this.pageSize = pageSize;
			this.offset = offset;
		}
	}
}