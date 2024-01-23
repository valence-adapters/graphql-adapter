/**
 * Exercises the GraphQLAdapter class.
 */
@IsTest
private class GraphQLAdapterTests implements HttpCalloutMock {

	private static valence.LinkContext context;

	static {
		context = new valence.LinkContext();
		context.linkName = 'Alpha';
		context.linkSourceName = 'accounts';
		context.batchSizeLimit = 2;
		context.mappings = new Map<String, valence.Mapping>{
			'one' => valence.ValenceTestUtil.createTestMapping('one', 'name', null, null)
		};
		context.suggestedQueryFields = new List<valence.FieldPath>{
			valence.FieldPath.buildPath('name')
		};
	}

	/**
	 * Handle generating fake responses to our outbound HTTP requests.
	 *
	 * We use different fake names of NamedCredentials to select which reply we want to get back from our mock.
	 *
	 * @param req The request that would have been sent to the external API
	 *
	 * @return A mocked response from the API
	 */
	public static HttpResponse respond(HttpRequest req) {

		HttpResponse res = new HttpResponse();
		res.setStatusCode(200);
		res.setStatus('OK');

		if(req.getEndpoint().startsWith('callout:fetchArguments')) {
			switch on req.getHeader('Callout-Number') {
				when '1' { // fetching access token
					res.setBody(SAMPLE_ACCESS_TOKEN_RESPONSE);
				}

				when '2' { // fetching query list
					res.setBody(SAMPLE_QUERY_AND_MUTATION_TYPE_RESPONSE);
				}
			}
		}
		else if(req.getEndpoint().startsWith('callout:getTables')) {
			switch on req.getHeader('Callout-Number') {
				when '1' { // fetching access token
					res.setBody(SAMPLE_ACCESS_TOKEN_RESPONSE);
				}

				when '2', '3' { // fetching query list or mutation list
					res.setBody(SAMPLE_QUERY_AND_MUTATION_TYPE_RESPONSE);
				}
			}
		}
		else if(req.getEndpoint().startsWith('callout:getFieldsAccounts')) {
			switch on req.getHeader('Callout-Number') {
				when '1' { // fetching access token
					res.setBody(SAMPLE_ACCESS_TOKEN_RESPONSE);
				}

				when '2' { // fetching query list
					res.setBody(SAMPLE_QUERY_AND_MUTATION_TYPE_RESPONSE);
				}

				when '3' { // fetching full node for 'Accounts'
					res.setBody(SAMPLE_FULL_TYPE_RESPONSE_ACCOUNTS);
				}
			}
		}
		else if(req.getEndpoint().startsWith('callout:getFieldsAcknowledgements')) {
			switch on req.getHeader('Callout-Number') {
				when '1' { // fetching access token
					res.setBody(SAMPLE_ACCESS_TOKEN_RESPONSE);
				}

				when '2' { // fetching query list
					res.setBody(SAMPLE_QUERY_AND_MUTATION_TYPE_RESPONSE);
				}

				when '3' { // fetching full node for 'Acknowledgement'
					res.setBody(SAMPLE_FULL_TYPE_RESPONSE_ACKNOWLEDGEMENTS);
				}
			}
		}
		else if(req.getEndpoint().startsWith('callout:getLazyFieldChildren')) {
			switch on req.getHeader('Callout-Number') {
				when '1' { // fetching access token
					res.setBody(SAMPLE_ACCESS_TOKEN_RESPONSE);
				}

				when '2' { // fetching query list
					res.setBody(SAMPLE_QUERY_AND_MUTATION_TYPE_RESPONSE);
				}

				when '3' { // fetching full node for 'Balance'
					res.setBody(SAMPLE_FULL_TYPE_RESPONSE_BALANCE);
				}
			}
		}
		else if(req.getEndpoint().startsWith('callout:planFetchAccountsNoRecords')) {
			switch on req.getHeader('Callout-Number') {
				when '1' { // fetching access token
					res.setBody(SAMPLE_ACCESS_TOKEN_RESPONSE);
				}

				when '2' { // fetching query list
					res.setBody(SAMPLE_QUERY_AND_MUTATION_TYPE_RESPONSE);
				}

				when '3' { // fetching a single record so we can get headers
					res.setBody(SAMPLE_ACCOUNTS_RECORD_FETCH_NO_RECORDS);
				}
			}
		}
		else if(req.getEndpoint().startsWith('callout:planFetchAccountsImmediate')) {
			switch on req.getHeader('Callout-Number') {
				when '1' { // fetching access token
					res.setBody(SAMPLE_ACCESS_TOKEN_RESPONSE);
				}

				when '2' { // fetching query list
					res.setBody(SAMPLE_QUERY_AND_MUTATION_TYPE_RESPONSE);
				}

				when '3' { // fetching a single record so we can get headers
					res.setBody(SAMPLE_ACCOUNTS_RECORD_FETCH_ALL_RECORDS);
				}
			}
		}
		else if(req.getEndpoint().startsWith('callout:planFetchAccountsScopes')) {
			switch on req.getHeader('Callout-Number') {
				when '1' { // fetching access token
					res.setBody(SAMPLE_ACCESS_TOKEN_RESPONSE);
				}

				when '2' { // fetching query list
					res.setBody(SAMPLE_QUERY_AND_MUTATION_TYPE_RESPONSE);
				}

				when '3' { // fetching a single record so we can get headers
					res.setBody(SAMPLE_ACCOUNTS_RECORD_FETCH_RECORDS_MORE_LEFT);
				}
			}
		}
		else if(req.getEndpoint().startsWith('callout:planFetchAcknowledgements')) {
			switch on req.getHeader('Callout-Number') {
				when '1' { // fetching access token
					res.setBody(SAMPLE_ACCESS_TOKEN_RESPONSE);
				}

				when '2' { // fetching query list
					res.setBody(SAMPLE_QUERY_AND_MUTATION_TYPE_RESPONSE);
				}
			}
		}
		else if(req.getEndpoint().startsWith('callout:fetchRecordsPageableImmediate')) {
			switch on req.getHeader('Callout-Number') {
				when '1' { // fetching access token
					res.setBody(SAMPLE_ACCESS_TOKEN_RESPONSE);
				}

				when '2' { // fetching query list
					res.setBody(SAMPLE_QUERY_AND_MUTATION_TYPE_RESPONSE);
				}

				when '3', '4' { // fetching a single record so we can get headers, then fetching all records
					res.setBody(SAMPLE_ACCOUNTS_RECORD_FETCH_ALL_RECORDS);
				}
			}
		}
		else if(req.getEndpoint().startsWith('callout:fetchRecordsPageableScoped')) {
			switch on req.getHeader('Callout-Number') {
				when '1' { // fetching access token
					res.setBody(SAMPLE_ACCESS_TOKEN_RESPONSE);
				}

				when '2' { // fetching the batch of records
					res.setBody(SAMPLE_ACCOUNTS_RECORD_FETCH_RECORDS_MORE_LEFT);
				}
			}
		}
		else if(req.getEndpoint().startsWith('callout:fetchRecordsNonPageable')) {
			switch on req.getHeader('Callout-Number') {
				when '1' { // fetching access token
					res.setBody(SAMPLE_ACCESS_TOKEN_RESPONSE);
				}

				when '2' { // fetching all records
					res.setBody(SAMPLE_ACKNOWLEDGEMENTS_RECORD_FETCH_ALL_RECORDS);
				}
			}
		}
		else if(req.getEndpoint().startsWith('callout:fetchRecordsPartialErrors')) {
			switch on req.getHeader('Callout-Number') {
				when '1' { // fetching access token
					res.setBody(SAMPLE_ACCESS_TOKEN_RESPONSE);
				}

				when '2' { // fetching the batch of records that has some record-level errors
					res.setBody(SAMPLE_ACCOUNTS_RECORD_FETCH_PARTIAL_ERRORS);
				}
			}
		}
		else if(req.getEndpoint().startsWith('callout:fetchRecordsHTTPError')) {
			switch on req.getHeader('Callout-Number') {
				when '1' { // fetching access token
					res.setBody(SAMPLE_ACCESS_TOKEN_RESPONSE);
				}

				when '2' { // simulate a big-time failure
					res.setStatusCode(500);
					res.setStatus('Internal DB is busted.');
				}
			}
		}
		else if(req.getEndpoint().startsWith('callout:fetchAccessToken')) {
			res.setBody(SAMPLE_ACCESS_TOKEN_RESPONSE);
		}

		if(res.getStatusCode() == 200 && String.isBlank(res.getBody())) {
			throw new AdapterTestException('Unable to find mock for ' + req.getEndpoint() + ' [calloutNumber: ' + req.getHeader('Callout-Number') + ']');
		}

		return res;
	}

	@IsTest static void testConfigurableSourceAdapter() {

		GraphQLAdapter adapter = new GraphQLAdapter();

		System.assertEquals('c:graphQLAdapterSourceConfigurator', adapter.getSourceConfigurationLightningComponent(null));
		System.assertEquals(null, adapter.getSourceConfigurationStructure(null));

		String config = '{"arguments":[{"name":"statuses","fullType":"[AccountStatus!]","value":["OPEN","PENDING"]}]}';

		System.assertEquals('There are (1) parameters that will be added to GraphQL queries.', adapter.explainSourceConfiguration(null, config));

		System.assertEquals('No additional parameters are configured.', adapter.explainSourceConfiguration(null, '{"arguments":[]}'));

		System.assertEquals('No additional parameters are configured.', adapter.explainSourceConfiguration(null, null));

		System.assertEquals(null, adapter.sourceConfig);
		adapter.setSourceConfiguration(null, config);

		System.assertNotEquals(null, adapter.sourceConfig);
		System.assertEquals(1, adapter.sourceConfig.arguments.size());
		System.assertEquals('statuses', adapter.sourceConfig.arguments[0].name);
		System.assertEquals('[AccountStatus!]', adapter.sourceConfig.arguments[0].fullType);
		System.assertEquals(new List<String>{'OPEN', 'PENDING'}, adapter.sourceConfig.arguments[0].value);
	}

	@IsTest static void testNamedCredentialAdapter() {

		GraphQLAdapter adapter = new GraphQLAdapter();

		System.assertEquals(null, adapter.namedCredential);
		adapter.setNamedCredential('NewCredential');
		System.assertEquals('NewCredential', adapter.namedCredential);
	}

	@IsTest static void testSourceAdapterScopeSerialization() {

		GraphQLAdapter.FetchScope testScope = new GraphQLAdapter.FetchScope(7, 12);

		GraphQLAdapter adapter = new GraphQLAdapter();

		String serialized = adapter.serializeScope(testScope);

		System.assertEquals('{"pageSize":7,"offset":12}', serialized);

		GraphQLAdapter.FetchScope deserialized = (GraphQLAdapter.FetchScope)adapter.deserializeScope(serialized);

		System.assertEquals(testScope.offset, deserialized.offset);
		System.assertEquals(testScope.pageSize, deserialized.pageSize);
	}

	@IsTest static void testGetTables() {

		Test.setMock(HttpCalloutMock.class, new GraphQLAdapterTests());

		GraphQLAdapter adapter = new GraphQLAdapter();

		adapter.setNamedCredential('getTables');

		List<valence.Table> tables = adapter.getTables();

		System.assertEquals(20, tables.size());

		System.assertEquals('accounts', tables[0].name);
		System.assertEquals(false, tables[0].isEditable);
		System.assertEquals(true, tables[0].isReadable);

		System.assertEquals('createGrant', tables[19].name);
		System.assertEquals(true, tables[19].isEditable);
		System.assertEquals(false, tables[19].isReadable);
	}

	/**
	 * 'accounts' is a paginated query, so here we're testing the ability to drill into and find the inner type with the actual fields we care about.
	 */
	@IsTest static void testGetFieldsAccounts() {

		Test.setMock(HttpCalloutMock.class, new GraphQLAdapterTests());

		GraphQLAdapter adapter = new GraphQLAdapter();

		adapter.setNamedCredential('getFieldsAccounts');

		List<valence.Field> fields = adapter.getFields('accounts');

		System.assertEquals(16, fields.size());

		System.assertEquals('amountRequiringBoardApprovals', fields[0].name);
		System.assertEquals(false, fields[0].isEditable);
		System.assertEquals(null, fields[0].description);
		System.assertEquals('Decimal', fields[0].type);
		System.assertEquals(false, fields[0].isList);
		System.assertEquals(false, fields[0].isMap);
		System.assertEquals(false, fields[0].isLazy);
		System.assertEquals(true, fields[0].isRequired);

		System.assertEquals('balance', fields[1].name);
		System.assertEquals(false, fields[1].isEditable);
		System.assertEquals(null, fields[1].description);
		System.assertEquals('Balance', fields[1].type);
		System.assertEquals(false, fields[1].isList);
		System.assertEquals(true, fields[1].isMap);
		System.assertEquals(true, fields[1].isLazy);
		System.assertEquals(false, fields[1].isRequired);

		System.assertEquals('boardApprovalRequired', fields[2].name);
		System.assertEquals(false, fields[2].isEditable);
		System.assertEquals(null, fields[2].description);
		System.assertEquals('Boolean', fields[2].type);
		System.assertEquals(false, fields[2].isList);
		System.assertEquals(false, fields[2].isMap);
		System.assertEquals(false, fields[2].isLazy);
		System.assertEquals(true, fields[2].isRequired);

		System.assertEquals('closedDate', fields[3].name);
		System.assertEquals(false, fields[3].isEditable);
		System.assertEquals(null, fields[3].description);
		System.assertEquals('DateTime', fields[3].type);
		System.assertEquals(false, fields[3].isList);
		System.assertEquals(false, fields[3].isMap);
		System.assertEquals(false, fields[3].isLazy);
		System.assertEquals(false, fields[3].isRequired);

		System.assertEquals('code', fields[4].name);
		System.assertEquals(false, fields[4].isEditable);
		System.assertEquals(null, fields[4].description);
		System.assertEquals('String', fields[4].type);
		System.assertEquals(false, fields[4].isList);
		System.assertEquals(false, fields[4].isMap);
		System.assertEquals(false, fields[4].isLazy);
		System.assertEquals(true, fields[4].isRequired);

		System.assertEquals('externalId', fields[5].name);
		System.assertEquals(false, fields[5].isEditable);
		System.assertEquals(null, fields[5].description);
		System.assertEquals('ID', fields[5].type);
		System.assertEquals(false, fields[5].isList);
		System.assertEquals(false, fields[5].isMap);
		System.assertEquals(false, fields[5].isLazy);
		System.assertEquals(true, fields[5].isRequired);

		System.assertEquals('grants', fields[6].name);
		System.assertEquals(false, fields[6].isEditable);
		System.assertEquals(null, fields[6].description);
		System.assertEquals('LIST<Grant>', fields[6].type);
		System.assertEquals(true, fields[6].isList);
		System.assertEquals(true, fields[6].isMap);
		System.assertEquals(true, fields[6].isLazy);
		System.assertEquals(false, fields[6].isRequired);

		System.assertEquals('id', fields[7].name);
		System.assertEquals(false, fields[7].isEditable);
		System.assertEquals(null, fields[7].description);
		System.assertEquals('ID', fields[7].type);
		System.assertEquals(false, fields[7].isList);
		System.assertEquals(false, fields[7].isMap);
		System.assertEquals(false, fields[7].isLazy);
		System.assertEquals(true, fields[7].isRequired);

		System.assertEquals('name', fields[8].name);
		System.assertEquals(false, fields[8].isEditable);
		System.assertEquals(null, fields[8].description);
		System.assertEquals('String', fields[8].type);
		System.assertEquals(false, fields[8].isList);
		System.assertEquals(false, fields[8].isMap);
		System.assertEquals(false, fields[8].isLazy);
		System.assertEquals(true, fields[8].isRequired);

		System.assertEquals('openedDate', fields[9].name);
		System.assertEquals(false, fields[9].isEditable);
		System.assertEquals(null, fields[9].description);
		System.assertEquals('DateTime', fields[9].type);
		System.assertEquals(false, fields[9].isList);
		System.assertEquals(false, fields[9].isMap);
		System.assertEquals(false, fields[9].isLazy);
		System.assertEquals(false, fields[9].isRequired);

		System.assertEquals('otherPayments', fields[10].name);
		System.assertEquals(false, fields[10].isEditable);
		System.assertEquals(null, fields[10].description);
		System.assertEquals('OtherPayments', fields[10].type);
		System.assertEquals(false, fields[10].isList);
		System.assertEquals(true, fields[10].isMap);
		System.assertEquals(true, fields[10].isLazy);
		System.assertEquals(true, fields[10].isRequired);

		System.assertEquals('program', fields[11].name);
		System.assertEquals(false, fields[11].isEditable);
		System.assertEquals(null, fields[11].description);
		System.assertEquals('Program', fields[11].type);
		System.assertEquals(false, fields[11].isList);
		System.assertEquals(true, fields[11].isMap);
		System.assertEquals(true, fields[11].isLazy);
		System.assertEquals(true, fields[11].isRequired);

		System.assertEquals('roles', fields[12].name);
		System.assertEquals(false, fields[12].isEditable);
		System.assertEquals(null, fields[12].description);
		System.assertEquals('AccountRoles', fields[12].type);
		System.assertEquals(false, fields[12].isList);
		System.assertEquals(true, fields[12].isMap);
		System.assertEquals(true, fields[12].isLazy);
		System.assertEquals(true, fields[12].isRequired);

		System.assertEquals('status', fields[13].name);
		System.assertEquals(false, fields[13].isEditable);
		System.assertEquals(null, fields[13].description);
		System.assertEquals('AccountStatus', fields[13].type);
		System.assertEquals(false, fields[13].isList);
		System.assertEquals(false, fields[13].isMap);
		System.assertEquals(false, fields[13].isLazy);
		System.assertEquals(true, fields[13].isRequired);

		System.assertEquals('subtype', fields[14].name);
		System.assertEquals(false, fields[14].isEditable);
		System.assertEquals(null, fields[14].description);
		System.assertEquals('AccountSubtype', fields[14].type);
		System.assertEquals(false, fields[14].isList);
		System.assertEquals(false, fields[14].isMap);
		System.assertEquals(false, fields[14].isLazy);
		System.assertEquals(true, fields[14].isRequired);

		System.assertEquals('type', fields[15].name);
		System.assertEquals(false, fields[15].isEditable);
		System.assertEquals(null, fields[15].description);
		System.assertEquals('AccountType', fields[15].type);
		System.assertEquals(false, fields[15].isList);
		System.assertEquals(false, fields[15].isMap);
		System.assertEquals(false, fields[15].isLazy);
		System.assertEquals(true, fields[15].isRequired);
	}

	/**
	 * 'acknowledgements' is not a paginated query, so we are expecting to find fields right away on the top-level type.
	 */
	@IsTest static void testGetFieldsAcknowledgements() {

		Test.setMock(HttpCalloutMock.class, new GraphQLAdapterTests());

		GraphQLAdapter adapter = new GraphQLAdapter();

		adapter.setNamedCredential('getFieldsAcknowledgements');

		List<valence.Field> fields = adapter.getFields('acknowledgements');

		System.assertEquals(2, fields.size());

		System.assertEquals('description', fields[0].name);
		System.assertEquals(false, fields[0].isEditable);
		System.assertEquals(null, fields[0].description);
		System.assertEquals('String', fields[0].type);
		System.assertEquals(false, fields[0].isList);
		System.assertEquals(false, fields[0].isMap);
		System.assertEquals(false, fields[0].isLazy);
		System.assertEquals(false, fields[0].isRequired);

		System.assertEquals('id', fields[1].name);
		System.assertEquals(false, fields[1].isEditable);
		System.assertEquals(null, fields[1].description);
		System.assertEquals('Int', fields[1].type);
		System.assertEquals(false, fields[1].isList);
		System.assertEquals(false, fields[1].isMap);
		System.assertEquals(false, fields[1].isLazy);
		System.assertEquals(true, fields[1].isRequired);
	}

	/**
	 * Since we have a nested graph, sometimes we have to drill deeper to get more fields.
	 */
	@IsTest static void testGetLazyFieldChildren() {

		Test.setMock(HttpCalloutMock.class, new GraphQLAdapterTests());

		GraphQLAdapter adapter = new GraphQLAdapter();
		adapter.setNamedCredential('getLazyFieldChildren');

		// inspect the 'balance' field on the 'accounts' query
		List<valence.Field> fields = adapter.getLazyFieldChildren('accounts', new List<valence.Field>{valence.Field.create('balance').build()});

		System.assertEquals(5, fields.size());

		System.assertEquals('accountId', fields[0].name);
		System.assertEquals(false, fields[0].isEditable);
		System.assertEquals(null, fields[0].description);
		System.assertEquals('ID', fields[0].type);
		System.assertEquals(false, fields[0].isList);
		System.assertEquals(false, fields[0].isMap);
		System.assertEquals(false, fields[0].isLazy);
		System.assertEquals(true, fields[0].isRequired);

		System.assertEquals('actual', fields[1].name);
		System.assertEquals(false, fields[1].isEditable);
		System.assertEquals(null, fields[1].description);
		System.assertEquals('Decimal', fields[1].type);
		System.assertEquals(false, fields[1].isList);
		System.assertEquals(false, fields[1].isMap);
		System.assertEquals(false, fields[1].isLazy);
		System.assertEquals(true, fields[1].isRequired);

		System.assertEquals('actualEffectiveDate', fields[2].name);
		System.assertEquals(false, fields[2].isEditable);
		System.assertEquals(null, fields[2].description);
		System.assertEquals('DateTime', fields[2].type);
		System.assertEquals(false, fields[2].isList);
		System.assertEquals(false, fields[2].isMap);
		System.assertEquals(false, fields[2].isLazy);
		System.assertEquals(true, fields[2].isRequired);

		System.assertEquals('available', fields[3].name);
		System.assertEquals(false, fields[3].isEditable);
		System.assertEquals(null, fields[3].description);
		System.assertEquals('Decimal', fields[3].type);
		System.assertEquals(false, fields[3].isList);
		System.assertEquals(false, fields[3].isMap);
		System.assertEquals(false, fields[3].isLazy);
		System.assertEquals(true, fields[3].isRequired);

		System.assertEquals('pending', fields[4].name);
		System.assertEquals(false, fields[4].isEditable);
		System.assertEquals(null, fields[4].description);
		System.assertEquals('Decimal', fields[4].type);
		System.assertEquals(false, fields[4].isList);
		System.assertEquals(false, fields[4].isMap);
		System.assertEquals(false, fields[4].isLazy);
		System.assertEquals(true, fields[4].isRequired);
	}

	@IsTest static void testGetFieldsNonexistentTable() {

		Test.setMock(HttpCalloutMock.class, new GraphQLAdapterTests());

		GraphQLAdapter adapter = new GraphQLAdapter();

		adapter.setNamedCredential('getFieldsAccounts');

		try {
			List<valence.Field> fields = adapter.getFields('fakeTable');
			System.assert(false, 'Expected an exception because this table does not exist.');
		}
		catch(valence.AdapterException e) {
			System.assertEquals('Could not locate a GraphQL query matching <fakeTable>.', e.getMessage());
		}
	}

	/**
	 * Test the scenario where we go to plan our fetch and the query does not support pagination, causing us to do an immediate strategy.
	 */
	@IsTest static void testPlanFetchNotPageable() {

		Test.setMock(HttpCalloutMock.class, new GraphQLAdapterTests());

		GraphQLAdapter adapter = new GraphQLAdapter();
		adapter.setNamedCredential('planFetchAcknowledgements');
		adapter.setSourceConfiguration(null, null);

		context.linkSourceName = 'acknowledgements';

		valence.FetchStrategy strategy = adapter.planFetch(context);

		System.assertEquals(false, adapter.currentInnerTypeIsPageable);
	}

	@IsTest static void testPlanFetchNoRecords() {

		Test.setMock(HttpCalloutMock.class, new GraphQLAdapterTests());

		GraphQLAdapter adapter = new GraphQLAdapter();
		adapter.setNamedCredential('planFetchAccountsNoRecords');
		adapter.setSourceConfiguration(null, null);

		valence.FetchStrategy strategy = adapter.planFetch(context);

		System.assertEquals(true, adapter.currentInnerTypeIsPageable);
	}

	/**
	 * Test the scenario where we go to plan our fetch and the query does not support pagination, causing us to do an immediate strategy.
	 */
	@IsTest static void testPlanFetchImmediate() {

		Test.setMock(HttpCalloutMock.class, new GraphQLAdapterTests());

		GraphQLAdapter adapter = new GraphQLAdapter();
		adapter.setNamedCredential('planFetchAccountsImmediate');
		adapter.setSourceConfiguration(null, null);

		valence.FetchStrategy strategy = adapter.planFetch(context);

		System.assertEquals(true, adapter.currentInnerTypeIsPageable);
	}

	@IsTest static void testPlanFetchScopes() {

		Test.setMock(HttpCalloutMock.class, new GraphQLAdapterTests());

		GraphQLAdapter adapter = new GraphQLAdapter();
		adapter.setNamedCredential('planFetchAccountsScopes');
		adapter.setSourceConfiguration(null, null);

		valence.FetchStrategy strategy = adapter.planFetch(context);

		System.assertEquals(true, adapter.currentInnerTypeIsPageable);
	}

	@IsTest static void testFetchRecordsPageableImmediate() {

		Test.setMock(HttpCalloutMock.class, new GraphQLAdapterTests());

		GraphQLAdapter adapter = new GraphQLAdapter();
		adapter.setNamedCredential('fetchRecordsPageableImmediate');
		adapter.setSourceConfiguration(null, '{"arguments":[{"name":"statuses","fullType":"[AccountStatus!]","value":["OPEN","PENDING"]}]}');

		// we plan first so that currentInnerTypeIsPageable is set appropriately
		valence.FetchStrategy strategy = adapter.planFetch(context);

		System.assertEquals(true, adapter.currentInnerTypeIsPageable);

		List<valence.RecordInFlight> records = adapter.fetchRecords(context, null);

		System.assertEquals(1, records.size());

		System.assertEquals('Acme', records[0].getOriginalProperties().get('name'));
	}

	@IsTest static void testFetchRecordsPartialErrors() {

		Test.setMock(HttpCalloutMock.class, new GraphQLAdapterTests());

		GraphQLAdapter adapter = new GraphQLAdapter();
		adapter.setNamedCredential('fetchRecordsPartialErrors');
		adapter.setSourceConfiguration(null, null);
		adapter.currentInnerTypeIsPageable = true;

		context.mappings = new Map<String, valence.Mapping>{
			'one' => valence.ValenceTestUtil.createTestMapping('one', 'name', null, null),
			'two' => valence.ValenceTestUtil.createTestMapping('two', 'balance', null, null)
		};
		context.suggestedQueryFields = new List<valence.FieldPath> {
			valence.FieldPath.buildPath('name'),
			valence.FieldPath.buildPath('balance')
		};

		List<valence.RecordInFlight> records = adapter.fetchRecords(context, null);

		System.assertEquals(2, records.size());

		System.assertEquals('Acme', records[0].getOriginalProperties().get('name'));
		System.assertEquals(1200, records[0].getOriginalProperties().get('balance'));
		System.assertEquals(false, records[0].hasErrors());

		System.assertEquals('Baker', records[1].getOriginalProperties().get('name'));
		System.assertEquals(null, records[1].getOriginalProperties().get('balance'));
		System.assertEquals(true, records[1].hasErrors());
	}

	@IsTest static void testFetchRecordsHTTPFailure() {

		Test.setMock(HttpCalloutMock.class, new GraphQLAdapterTests());

		GraphQLAdapter adapter = new GraphQLAdapter();
		adapter.setNamedCredential('fetchRecordsHTTPError');
		adapter.setSourceConfiguration(null, null);
		adapter.currentInnerTypeIsPageable = true;

		context.mappings = new Map<String, valence.Mapping>{
			'one' => valence.ValenceTestUtil.createTestMapping('one', 'name', null, null),
			'two' => valence.ValenceTestUtil.createTestMapping('two', 'balance', null, null)
		};
		context.suggestedQueryFields = new List<valence.FieldPath> {
			valence.FieldPath.buildPath('name'),
			valence.FieldPath.buildPath('balance')
		};

		try {
			List<valence.RecordInFlight> records = adapter.fetchRecords(context, null);
			System.assert(false, 'Expected an exception.');
		}
		catch(valence.AdapterException e) {
			System.assertEquals('500:Internal DB is busted.:', e.getMessage());
		}
	}

	@IsTest static void testFetchRecordsNonPageable() {

		Test.setMock(HttpCalloutMock.class, new GraphQLAdapterTests());

		GraphQLAdapter adapter = new GraphQLAdapter();
		adapter.setNamedCredential('fetchRecordsNonPageable');
		adapter.setSourceConfiguration(null, null);

		context.linkSourceName = 'acknowledgements';
		context.mappings = new Map<String, valence.Mapping>{
			'one' => valence.ValenceTestUtil.createTestMapping('one', 'id', null, null),
			'two' => valence.ValenceTestUtil.createTestMapping('two', 'description', null, null)
		};
		context.suggestedQueryFields = new List<valence.FieldPath> {
			valence.FieldPath.buildPath('id'),
			valence.FieldPath.buildPath('description')
		};

		List<valence.RecordInFlight> records = adapter.fetchRecords(context, null);

		System.assertEquals(1, records.size());

		System.assertEquals(123, records[0].getOriginalProperties().get('id'));
		System.assertEquals('Sample', records[0].getOriginalProperties().get('description'));
	}

	@IsTest static void testFetchAccessToken() {

		Test.setMock(HttpCalloutMock.class, new GraphQLAdapterTests());

		GraphQLAdapter adapter = new GraphQLAdapter();
		adapter.setNamedCredential('fetchAccessToken');

		System.assertEquals(null, adapter.accessToken);
		adapter.fetchAccessToken();
		System.assertEquals('SampleToken', adapter.accessToken);
	}

	@IsTest static void testFetchQueryArgumentDefinitions() {

		Test.setMock(HttpCalloutMock.class, new GraphQLAdapterTests());

		// fetchQueryArgumentDefinitions has a baked-in Test.isRunningTest scenario that will load and parse SAMPLE_FETCH_ARGUMENTS
		List<GraphQLAdapter.Argument> args = GraphQLAdapter.fetchQueryArgumentDefinitions('fakeLink');

		System.assertEquals(5, args.size());
		System.debug(LoggingLevel.WARN, args[0]);

		System.assertEquals(true, args[0].areItemsRequired);
		System.assertEquals(null, args[0].defaultValue);
		System.assertEquals(null, args[0].enumValues);
		System.assertEquals('[String!]', args[0].fullType);
		System.assertEquals(false, args[0].isEnum);
		System.assertEquals(true, args[0].isList);
		System.assertEquals(false, args[0].isRequired);
		System.assertEquals('codes', args[0].name);
		System.assertEquals('String', args[0].simpleType);
		System.assertEquals(null, args[0].value);

		System.assertEquals(true, args[1].areItemsRequired);
		System.assertEquals(null, args[1].defaultValue);
		System.assertEquals(null, args[1].enumValues);
		System.assertEquals('[String!]', args[1].fullType);
		System.assertEquals(false, args[1].isEnum);
		System.assertEquals(true, args[1].isList);
		System.assertEquals(false, args[1].isRequired);
		System.assertEquals('externalIds', args[1].name);
		System.assertEquals('String', args[1].simpleType);
		System.assertEquals(null, args[1].value);

		System.assertEquals(true, args[2].areItemsRequired);
		System.assertEquals(null, args[2].defaultValue);
		System.assertEquals(null, args[2].enumValues);
		System.assertEquals('[ID!]', args[2].fullType);
		System.assertEquals(false, args[2].isEnum);
		System.assertEquals(true, args[2].isList);
		System.assertEquals(false, args[2].isRequired);
		System.assertEquals('ids', args[2].name);
		System.assertEquals('ID', args[2].simpleType);
		System.assertEquals(null, args[2].value);

		System.assertEquals(true, args[3].areItemsRequired);
		System.assertEquals(null, args[3].defaultValue);
		System.assertEquals(null, args[3].enumValues);
		System.assertEquals('[Int!]', args[3].fullType);
		System.assertEquals(false, args[3].isEnum);
		System.assertEquals(true, args[3].isList);
		System.assertEquals(false, args[3].isRequired);
		System.assertEquals('programIds', args[3].name);
		System.assertEquals('Int', args[3].simpleType);
		System.assertEquals(null, args[3].value);

		System.assertEquals(true, args[4].areItemsRequired);
		System.assertEquals(null, args[4].defaultValue);
		System.assertEquals(new List<String>{'CLOSED', 'OPEN', 'PENDING'}, args[4].enumValues);
		System.assertEquals('[AccountStatus!]', args[4].fullType);
		System.assertEquals(true, args[4].isEnum);
		System.assertEquals(true, args[4].isList);
		System.assertEquals(false, args[4].isRequired);
		System.assertEquals('statuses', args[4].name);
		System.assertEquals('AccountStatus', args[4].simpleType);
		System.assertEquals(null, args[4].value);
	}

	private class AdapterTestException extends Exception {
	}

	// sample API response when fetching an access token
	private static final String SAMPLE_ACCESS_TOKEN_RESPONSE = '{"accessToken":"SampleToken","expiresIn":3600,"refreshToken":null}';

	// sample API response when fetching all Query and Mutation types
	private static final String SAMPLE_QUERY_AND_MUTATION_TYPE_RESPONSE = '{"data":{"__schema":{"queryType":{"name":"Query","kind":"OBJECT","description":null,"enumValues":null,"interfaces":[],"fields":[{"name":"accounts","description":null,"args":[{"name":"codes","description":null,"defaultValue":null,"type":{"name":null,"kind":"LIST","description":null,"enumValues":null,"interfaces":null,"ofType":{"name":null,"kind":"NON_NULL","description":null,"enumValues":null,"interfaces":null,"ofType":{"name":"String","kind":"SCALAR","description":"The`String`scalartyperepresentstextualdata,representedasUTF-8charactersequences.TheStringtypeismostoftenusedbyGraphQLtorepresentfree-formhuman-readabletext.","enumValues":null,"interfaces":null,"ofType":null}}}},{"name":"externalIds","description":null,"defaultValue":null,"type":{"name":null,"kind":"LIST","description":null,"enumValues":null,"interfaces":null,"ofType":{"name":null,"kind":"NON_NULL","description":null,"enumValues":null,"interfaces":null,"ofType":{"name":"String","kind":"SCALAR","description":"The`String`scalartyperepresentstextualdata,representedasUTF-8charactersequences.TheStringtypeismostoftenusedbyGraphQLtorepresentfree-formhuman-readabletext.","enumValues":null,"interfaces":null,"ofType":null}}}},{"name":"ids","description":null,"defaultValue":null,"type":{"name":null,"kind":"LIST","description":null,"enumValues":null,"interfaces":null,"ofType":{"name":null,"kind":"NON_NULL","description":null,"enumValues":null,"interfaces":null,"ofType":{"name":"ID","kind":"SCALAR","description":"The`ID`scalartyperepresentsauniqueidentifier,oftenusedtorefetchanobjectoraskeyforacache.TheIDtypeappearsinaJSONresponseasaString;however,itisnotintendedtobehuman-readable.Whenexpectedasaninputtype,anystring(suchas`\\"4\\"`)orinteger(suchas`4`)inputvaluewillbeacceptedasanID.","enumValues":null,"interfaces":null,"ofType":null}}}},{"name":"limit","description":null,"defaultValue":null,"type":{"name":"Limit","kind":"INPUT_OBJECT","description":null,"enumValues":null,"interfaces":null,"ofType":null}},{"name":"programIds","description":null,"defaultValue":null,"type":{"name":null,"kind":"LIST","description":null,"enumValues":null,"interfaces":null,"ofType":{"name":null,"kind":"NON_NULL","description":null,"enumValues":null,"interfaces":null,"ofType":{"name":"Int","kind":"SCALAR","description":"The`Int`scalartyperepresentsnon-fractionalsignedwholenumericvalues.Intcanrepresentvaluesbetween-(2^31)and2^31-1.","enumValues":null,"interfaces":null,"ofType":null}}}},{"name":"statuses","description":null,"defaultValue":null,"type":{"name":null,"kind":"LIST","description":null,"enumValues":null,"interfaces":null,"ofType":{"name":null,"kind":"NON_NULL","description":null,"enumValues":null,"interfaces":null,"ofType":{"name":"AccountStatus","kind":"ENUM","description":null,"enumValues":[{"name":"CLOSED"},{"name":"OPEN"},{"name":"PENDING"}],"interfaces":null,"ofType":null}}}}],"type":{"name":null,"kind":"NON_NULL","description":null,"enumValues":null,"interfaces":null,"ofType":{"name":"Accounts","kind":"OBJECT","description":null,"enumValues":null,"interfaces":[{"name":"Pageable","kind":"INTERFACE","description":null}],"ofType":null}}},{"name":"acknowledgements","description":null,"args":[{"name":"programId","description":null,"defaultValue":null,"type":{"name":null,"kind":"NON_NULL","description":null,"enumValues":null,"interfaces":null,"ofType":{"name":"Int","kind":"SCALAR","description":"The`Int`scalartyperepresentsnon-fractionalsignedwholenumericvalues.Intcanrepresentvaluesbetween-(2^31)and2^31-1.","enumValues":null,"interfaces":null,"ofType":null}}}],"type":{"name":null,"kind":"NON_NULL","description":null,"enumValues":null,"interfaces":null,"ofType":{"name":null,"kind":"LIST","description":null,"enumValues":null,"interfaces":null,"ofType":{"name":null,"kind":"NON_NULL","description":null,"enumValues":null,"interfaces":null,"ofType":{"name":"Acknowledgement","kind":"OBJECT","description":null,"enumValues":null,"interfaces":[],"ofType":null}}}}},{"name":"apiresources","description":null,"args":[{"name":"limit","description":null,"defaultValue":null,"type":{"name":"Limit","kind":"INPUT_OBJECT","description":null,"enumValues":null,"interfaces":null,"ofType":null}}],"type":{"name":null,"kind":"NON_NULL","description":null,"enumValues":null,"interfaces":null,"ofType":{"name":"ApiResources","kind":"OBJECT","description":null,"enumValues":null,"interfaces":[{"name":"Pageable","kind":"INTERFACE","description":null}],"ofType":null}}},{"name":"blacklist","description":null,"args":[],"type":{"name":null,"kind":"NON_NULL","description":null,"enumValues":null,"interfaces":null,"ofType":{"name":"Blacklist","kind":"OBJECT","description":null,"enumValues":null,"interfaces":[],"ofType":null}}},{"name":"charities","description":null,"args":[{"name":"externalIds","description":null,"defaultValue":null,"type":{"name":null,"kind":"LIST","description":null,"enumValues":null,"interfaces":null,"ofType":{"name":null,"kind":"NON_NULL","description":null,"enumValues":null,"interfaces":null,"ofType":{"name":"String","kind":"SCALAR","description":"The`String`scalartyperepresentstextualdata,representedasUTF-8charactersequences.TheStringtypeismostoftenusedbyGraphQLtorepresentfree-formhuman-readabletext.","enumValues":null,"interfaces":null,"ofType":null}}}},{"name":"ids","description":null,"defaultValue":null,"type":{"name":null,"kind":"LIST","description":null,"enumValues":null,"interfaces":null,"ofType":{"name":null,"kind":"NON_NULL","description":null,"enumValues":null,"interfaces":null,"ofType":{"name":"Int","kind":"SCALAR","description":"The`Int`scalartyperepresentsnon-fractionalsignedwholenumericvalues.Intcanrepresentvaluesbetween-(2^31)and2^31-1.","enumValues":null,"interfaces":null,"ofType":null}}}},{"name":"limit","description":null,"defaultValue":null,"type":{"name":"Limit","kind":"INPUT_OBJECT","description":null,"enumValues":null,"interfaces":null,"ofType":null}}],"type":{"name":null,"kind":"NON_NULL","description":null,"enumValues":null,"interfaces":null,"ofType":{"name":"Charities","kind":"OBJECT","description":null,"enumValues":null,"interfaces":[{"name":"Pageable","kind":"INTERFACE","description":null}],"ofType":null}}},{"name":"charitiesSearch","description":null,"args":[{"name":"address","description":null,"defaultValue":null,"type":{"name":"AddressInput","kind":"INPUT_OBJECT","description":null,"enumValues":null,"interfaces":null,"ofType":null}},{"name":"limit","description":null,"defaultValue":null,"type":{"name":"Limit","kind":"INPUT_OBJECT","description":null,"enumValues":null,"interfaces":null,"ofType":null}},{"name":"programId","description":null,"defaultValue":null,"type":{"name":null,"kind":"NON_NULL","description":null,"enumValues":null,"interfaces":null,"ofType":{"name":"Int","kind":"SCALAR","description":"The`Int`scalartyperepresentsnon-fractionalsignedwholenumericvalues.Intcanrepresentvaluesbetween-(2^31)and2^31-1.","enumValues":null,"interfaces":null,"ofType":null}}},{"name":"searchTerm","description":null,"defaultValue":null,"type":{"name":null,"kind":"NON_NULL","description":null,"enumValues":null,"interfaces":null,"ofType":{"name":"String","kind":"SCALAR","description":"The`String`scalartyperepresentstextualdata,representedasUTF-8charactersequences.TheStringtypeismostoftenusedbyGraphQLtorepresentfree-formhuman-readabletext.","enumValues":null,"interfaces":null,"ofType":null}}}],"type":{"name":null,"kind":"NON_NULL","description":null,"enumValues":null,"interfaces":null,"ofType":{"name":"Charities","kind":"OBJECT","description":null,"enumValues":null,"interfaces":[{"name":"Pageable","kind":"INTERFACE","description":null}],"ofType":null}}},{"name":"dedications","description":null,"args":[{"name":"programId","description":null,"defaultValue":null,"type":{"name":null,"kind":"NON_NULL","description":null,"enumValues":null,"interfaces":null,"ofType":{"name":"Int","kind":"SCALAR","description":"The`Int`scalartyperepresentsnon-fractionalsignedwholenumericvalues.Intcanrepresentvaluesbetween-(2^31)and2^31-1.","enumValues":null,"interfaces":null,"ofType":null}}}],"type":{"name":null,"kind":"NON_NULL","description":null,"enumValues":null,"interfaces":null,"ofType":{"name":null,"kind":"LIST","description":null,"enumValues":null,"interfaces":null,"ofType":{"name":null,"kind":"NON_NULL","description":null,"enumValues":null,"interfaces":null,"ofType":{"name":"Dedication","kind":"OBJECT","description":null,"enumValues":null,"interfaces":[],"ofType":null}}}}},{"name":"deliverableAddress","description":null,"args":[{"name":"address","description":null,"defaultValue":null,"type":{"name":"String","kind":"SCALAR","description":"The`String`scalartyperepresentstextualdata,representedasUTF-8charactersequences.TheStringtypeismostoftenusedbyGraphQLtorepresentfree-formhuman-readabletext.","enumValues":null,"interfaces":null,"ofType":null}},{"name":"isInternational","description":null,"defaultValue":null,"type":{"name":"Boolean","kind":"SCALAR","description":"The`Boolean`scalartyperepresents`true`or`false`.","enumValues":null,"interfaces":null,"ofType":null}},{"name":"usAddress","description":null,"defaultValue":null,"type":{"name":"UsAddress","kind":"INPUT_OBJECT","description":null,"enumValues":null,"interfaces":null,"ofType":null}}],"type":{"name":"DeliverableAddress","kind":"OBJECT","description":null,"enumValues":null,"interfaces":[],"ofType":null}},{"name":"deliverymethods","description":null,"args":[{"name":"programId","description":null,"defaultValue":null,"type":{"name":null,"kind":"NON_NULL","description":null,"enumValues":null,"interfaces":null,"ofType":{"name":"Int","kind":"SCALAR","description":"The`Int`scalartyperepresentsnon-fractionalsignedwholenumericvalues.Intcanrepresentvaluesbetween-(2^31)and2^31-1.","enumValues":null,"interfaces":null,"ofType":null}}}],"type":{"name":null,"kind":"NON_NULL","description":null,"enumValues":null,"interfaces":null,"ofType":{"name":null,"kind":"LIST","description":null,"enumValues":null,"interfaces":null,"ofType":{"name":null,"kind":"NON_NULL","description":null,"enumValues":null,"interfaces":null,"ofType":{"name":"DeliveryMethod","kind":"OBJECT","description":null,"enumValues":null,"interfaces":[],"ofType":null}}}}},{"name":"grantpurposes","description":null,"args":[{"name":"programId","description":null,"defaultValue":null,"type":{"name":null,"kind":"NON_NULL","description":null,"enumValues":null,"interfaces":null,"ofType":{"name":"Int","kind":"SCALAR","description":"The`Int`scalartyperepresentsnon-fractionalsignedwholenumericvalues.Intcanrepresentvaluesbetween-(2^31)and2^31-1.","enumValues":null,"interfaces":null,"ofType":null}}}],"type":{"name":null,"kind":"NON_NULL","description":null,"enumValues":null,"interfaces":null,"ofType":{"name":null,"kind":"LIST","description":null,"enumValues":null,"interfaces":null,"ofType":{"name":null,"kind":"NON_NULL","description":null,"enumValues":null,"interfaces":null,"ofType":{"name":"GrantPurpose","kind":"OBJECT","description":null,"enumValues":null,"interfaces":[],"ofType":null}}}}},{"name":"grants","description":null,"args":[{"name":"accountExternalIds","description":null,"defaultValue":null,"type":{"name":null,"kind":"LIST","description":null,"enumValues":null,"interfaces":null,"ofType":{"name":null,"kind":"NON_NULL","description":null,"enumValues":null,"interfaces":null,"ofType":{"name":"String","kind":"SCALAR","description":"The`String`scalartyperepresentstextualdata,representedasUTF-8charactersequences.TheStringtypeismostoftenusedbyGraphQLtorepresentfree-formhuman-readabletext.","enumValues":null,"interfaces":null,"ofType":null}}}},{"name":"accountIds","description":null,"defaultValue":null,"type":{"name":null,"kind":"LIST","description":null,"enumValues":null,"interfaces":null,"ofType":{"name":null,"kind":"NON_NULL","description":null,"enumValues":null,"interfaces":null,"ofType":{"name":"Int","kind":"SCALAR","description":"The`Int`scalartyperepresentsnon-fractionalsignedwholenumericvalues.Intcanrepresentvaluesbetween-(2^31)and2^31-1.","enumValues":null,"interfaces":null,"ofType":null}}}},{"name":"clearedDateEnd","description":null,"defaultValue":null,"type":{"name":"Date","kind":"SCALAR","description":"The`Date`scalarrepresentsanISO-8601compliantdatetype.","enumValues":null,"interfaces":null,"ofType":null}},{"name":"clearedDateStart","description":null,"defaultValue":null,"type":{"name":"Date","kind":"SCALAR","description":"The`Date`scalarrepresentsanISO-8601compliantdatetype.","enumValues":null,"interfaces":null,"ofType":null}},{"name":"currentStatusDateEnd","description":null,"defaultValue":null,"type":{"name":"Date","kind":"SCALAR","description":"The`Date`scalarrepresentsanISO-8601compliantdatetype.","enumValues":null,"interfaces":null,"ofType":null}},{"name":"currentStatusDateStart","description":null,"defaultValue":null,"type":{"name":"Date","kind":"SCALAR","description":"The`Date`scalarrepresentsanISO-8601compliantdatetype.","enumValues":null,"interfaces":null,"ofType":null}},{"name":"currentStatuses","description":null,"defaultValue":null,"type":{"name":null,"kind":"LIST","description":null,"enumValues":null,"interfaces":null,"ofType":{"name":null,"kind":"NON_NULL","description":null,"enumValues":null,"interfaces":null,"ofType":{"name":"DisbursementStatus","kind":"ENUM","description":null,"enumValues":[{"name":"APPROVAL_NEEDED"},{"name":"CANCELED"},{"name":"CLEARED"},{"name":"DRAFT"},{"name":"PAYMENT_ISSUED"},{"name":"PAYMENT_PENDING"},{"name":"REDEMPTION_REQUESTED"},{"name":"UNKNOWN"},{"name":"VETTING"}],"interfaces":null,"ofType":null}}}},{"name":"ids","description":null,"defaultValue":null,"type":{"name":null,"kind":"LIST","description":null,"enumValues":null,"interfaces":null,"ofType":{"name":null,"kind":"NON_NULL","description":null,"enumValues":null,"interfaces":null,"ofType":{"name":"ID","kind":"SCALAR","description":"The`ID`scalartyperepresentsauniqueidentifier,oftenusedtorefetchanobjectoraskeyforacache.TheIDtypeappearsinaJSONresponseasaString;however,itisnotintendedtobehuman-readable.Whenexpectedasaninputtype,anystring(suchas`\\"4\\"`)orinteger(suchas`4`)inputvaluewillbeacceptedasanID.","enumValues":null,"interfaces":null,"ofType":null}}}},{"name":"isPending","description":null,"defaultValue":null,"type":{"name":"Boolean","kind":"SCALAR","description":"The`Boolean`scalartyperepresents`true`or`false`.","enumValues":null,"interfaces":null,"ofType":null}},{"name":"issuedDateEnd","description":null,"defaultValue":null,"type":{"name":"Date","kind":"SCALAR","description":"The`Date`scalarrepresentsanISO-8601compliantdatetype.","enumValues":null,"interfaces":null,"ofType":null}},{"name":"issuedDateStart","description":null,"defaultValue":null,"type":{"name":"Date","kind":"SCALAR","description":"The`Date`scalarrepresentsanISO-8601compliantdatetype.","enumValues":null,"interfaces":null,"ofType":null}},{"name":"limit","description":null,"defaultValue":null,"type":{"name":"Limit","kind":"INPUT_OBJECT","description":null,"enumValues":null,"interfaces":null,"ofType":null}},{"name":"orderBy","description":null,"defaultValue":null,"type":{"name":null,"kind":"LIST","description":null,"enumValues":null,"interfaces":null,"ofType":{"name":null,"kind":"NON_NULL","description":null,"enumValues":null,"interfaces":null,"ofType":{"name":"GrantOrderBy","kind":"INPUT_OBJECT","description":null,"enumValues":null,"interfaces":null,"ofType":null}}}},{"name":"programIds","description":null,"defaultValue":null,"type":{"name":null,"kind":"LIST","description":null,"enumValues":null,"interfaces":null,"ofType":{"name":null,"kind":"NON_NULL","description":null,"enumValues":null,"interfaces":null,"ofType":{"name":"Int","kind":"SCALAR","description":"The`Int`scalartyperepresentsnon-fractionalsignedwholenumericvalues.Intcanrepresentvaluesbetween-(2^31)and2^31-1.","enumValues":null,"interfaces":null,"ofType":null}}}},{"name":"recipientIds","description":null,"defaultValue":null,"type":{"name":null,"kind":"LIST","description":null,"enumValues":null,"interfaces":null,"ofType":{"name":null,"kind":"NON_NULL","description":null,"enumValues":null,"interfaces":null,"ofType":{"name":"Int","kind":"SCALAR","description":"The`Int`scalartyperepresentsnon-fractionalsignedwholenumericvalues.Intcanrepresentvaluesbetween-(2^31)and2^31-1.","enumValues":null,"interfaces":null,"ofType":null}}}}],"type":{"name":null,"kind":"NON_NULL","description":null,"enumValues":null,"interfaces":null,"ofType":{"name":"Grants","kind":"OBJECT","description":null,"enumValues":null,"interfaces":[{"name":"Pageable","kind":"INTERFACE","description":null}],"ofType":null}}},{"name":"oauthclients","description":null,"args":[{"name":"limit","description":null,"defaultValue":null,"type":{"name":"Limit","kind":"INPUT_OBJECT","description":null,"enumValues":null,"interfaces":null,"ofType":null}},{"name":"programIds","description":null,"defaultValue":null,"type":{"name":null,"kind":"LIST","description":null,"enumValues":null,"interfaces":null,"ofType":{"name":null,"kind":"NON_NULL","description":null,"enumValues":null,"interfaces":null,"ofType":{"name":"Int","kind":"SCALAR","description":"The`Int`scalartyperepresentsnon-fractionalsignedwholenumericvalues.Intcanrepresentvaluesbetween-(2^31)and2^31-1.","enumValues":null,"interfaces":null,"ofType":null}}}}],"type":{"name":null,"kind":"NON_NULL","description":null,"enumValues":null,"interfaces":null,"ofType":{"name":"OAuthClients","kind":"OBJECT","description":null,"enumValues":null,"interfaces":[{"name":"Pageable","kind":"INTERFACE","description":null}],"ofType":null}}},{"name":"otherPayments","description":null,"args":[{"name":"accountExternalIds","description":null,"defaultValue":null,"type":{"name":null,"kind":"LIST","description":null,"enumValues":null,"interfaces":null,"ofType":{"name":null,"kind":"NON_NULL","description":null,"enumValues":null,"interfaces":null,"ofType":{"name":"String","kind":"SCALAR","description":"The`String`scalartyperepresentstextualdata,representedasUTF-8charactersequences.TheStringtypeismostoftenusedbyGraphQLtorepresentfree-formhuman-readabletext.","enumValues":null,"interfaces":null,"ofType":null}}}},{"name":"accountIds","description":null,"defaultValue":null,"type":{"name":null,"kind":"LIST","description":null,"enumValues":null,"interfaces":null,"ofType":{"name":null,"kind":"NON_NULL","description":null,"enumValues":null,"interfaces":null,"ofType":{"name":"Int","kind":"SCALAR","description":"The`Int`scalartyperepresentsnon-fractionalsignedwholenumericvalues.Intcanrepresentvaluesbetween-(2^31)and2^31-1.","enumValues":null,"interfaces":null,"ofType":null}}}},{"name":"clearedDateEnd","description":null,"defaultValue":null,"type":{"name":"Date","kind":"SCALAR","description":"The`Date`scalarrepresentsanISO-8601compliantdatetype.","enumValues":null,"interfaces":null,"ofType":null}},{"name":"clearedDateStart","description":null,"defaultValue":null,"type":{"name":"Date","kind":"SCALAR","description":"The`Date`scalarrepresentsanISO-8601compliantdatetype.","enumValues":null,"interfaces":null,"ofType":null}},{"name":"currentStatusDateEnd","description":null,"defaultValue":null,"type":{"name":"Date","kind":"SCALAR","description":"The`Date`scalarrepresentsanISO-8601compliantdatetype.","enumValues":null,"interfaces":null,"ofType":null}},{"name":"currentStatusDateStart","description":null,"defaultValue":null,"type":{"name":"Date","kind":"SCALAR","description":"The`Date`scalarrepresentsanISO-8601compliantdatetype.","enumValues":null,"interfaces":null,"ofType":null}},{"name":"currentStatuses","description":null,"defaultValue":null,"type":{"name":null,"kind":"LIST","description":null,"enumValues":null,"interfaces":null,"ofType":{"name":null,"kind":"NON_NULL","description":null,"enumValues":null,"interfaces":null,"ofType":{"name":"DisbursementStatus","kind":"ENUM","description":null,"enumValues":[{"name":"APPROVAL_NEEDED"},{"name":"CANCELED"},{"name":"CLEARED"},{"name":"DRAFT"},{"name":"PAYMENT_ISSUED"},{"name":"PAYMENT_PENDING"},{"name":"REDEMPTION_REQUESTED"},{"name":"UNKNOWN"},{"name":"VETTING"}],"interfaces":null,"ofType":null}}}},{"name":"ids","description":null,"defaultValue":null,"type":{"name":null,"kind":"LIST","description":null,"enumValues":null,"interfaces":null,"ofType":{"name":null,"kind":"NON_NULL","description":null,"enumValues":null,"interfaces":null,"ofType":{"name":"ID","kind":"SCALAR","description":"The`ID`scalartyperepresentsauniqueidentifier,oftenusedtorefetchanobjectoraskeyforacache.TheIDtypeappearsinaJSONresponseasaString;however,itisnotintendedtobehuman-readable.Whenexpectedasaninputtype,anystring(suchas`\\"4\\"`)orinteger(suchas`4`)inputvaluewillbeacceptedasanID.","enumValues":null,"interfaces":null,"ofType":null}}}},{"name":"isPending","description":null,"defaultValue":null,"type":{"name":"Boolean","kind":"SCALAR","description":"The`Boolean`scalartyperepresents`true`or`false`.","enumValues":null,"interfaces":null,"ofType":null}},{"name":"issuedDateEnd","description":null,"defaultValue":null,"type":{"name":"Date","kind":"SCALAR","description":"The`Date`scalarrepresentsanISO-8601compliantdatetype.","enumValues":null,"interfaces":null,"ofType":null}},{"name":"issuedDateStart","description":null,"defaultValue":null,"type":{"name":"Date","kind":"SCALAR","description":"The`Date`scalarrepresentsanISO-8601compliantdatetype.","enumValues":null,"interfaces":null,"ofType":null}},{"name":"limit","description":null,"defaultValue":null,"type":{"name":"Limit","kind":"INPUT_OBJECT","description":null,"enumValues":null,"interfaces":null,"ofType":null}},{"name":"programIds","description":null,"defaultValue":null,"type":{"name":null,"kind":"LIST","description":null,"enumValues":null,"interfaces":null,"ofType":{"name":null,"kind":"NON_NULL","description":null,"enumValues":null,"interfaces":null,"ofType":{"name":"Int","kind":"SCALAR","description":"The`Int`scalartyperepresentsnon-fractionalsignedwholenumericvalues.Intcanrepresentvaluesbetween-(2^31)and2^31-1.","enumValues":null,"interfaces":null,"ofType":null}}}},{"name":"recipientIds","description":null,"defaultValue":null,"type":{"name":null,"kind":"LIST","description":null,"enumValues":null,"interfaces":null,"ofType":{"name":null,"kind":"NON_NULL","description":null,"enumValues":null,"interfaces":null,"ofType":{"name":"Int","kind":"SCALAR","description":"The`Int`scalartyperepresentsnon-fractionalsignedwholenumericvalues.Intcanrepresentvaluesbetween-(2^31)and2^31-1.","enumValues":null,"interfaces":null,"ofType":null}}}}],"type":{"name":null,"kind":"NON_NULL","description":null,"enumValues":null,"interfaces":null,"ofType":{"name":"OtherPayments","kind":"OBJECT","description":null,"enumValues":null,"interfaces":[{"name":"Pageable","kind":"INTERFACE","description":null}],"ofType":null}}},{"name":"programs","description":null,"args":[{"name":"codes","description":null,"defaultValue":null,"type":{"name":null,"kind":"LIST","description":null,"enumValues":null,"interfaces":null,"ofType":{"name":null,"kind":"NON_NULL","description":null,"enumValues":null,"interfaces":null,"ofType":{"name":"String","kind":"SCALAR","description":"The`String`scalartyperepresentstextualdata,representedasUTF-8charactersequences.TheStringtypeismostoftenusedbyGraphQLtorepresentfree-formhuman-readabletext.","enumValues":null,"interfaces":null,"ofType":null}}}},{"name":"ids","description":null,"defaultValue":null,"type":{"name":null,"kind":"LIST","description":null,"enumValues":null,"interfaces":null,"ofType":{"name":null,"kind":"NON_NULL","description":null,"enumValues":null,"interfaces":null,"ofType":{"name":"ID","kind":"SCALAR","description":"The`ID`scalartyperepresentsauniqueidentifier,oftenusedtorefetchanobjectoraskeyforacache.TheIDtypeappearsinaJSONresponseasaString;however,itisnotintendedtobehuman-readable.Whenexpectedasaninputtype,anystring(suchas`\\"4\\"`)orinteger(suchas`4`)inputvaluewillbeacceptedasanID.","enumValues":null,"interfaces":null,"ofType":null}}}},{"name":"limit","description":null,"defaultValue":null,"type":{"name":"Limit","kind":"INPUT_OBJECT","description":null,"enumValues":null,"interfaces":null,"ofType":null}}],"type":{"name":null,"kind":"NON_NULL","description":null,"enumValues":null,"interfaces":null,"ofType":{"name":"Programs","kind":"OBJECT","description":null,"enumValues":null,"interfaces":[{"name":"Pageable","kind":"INTERFACE","description":null}],"ofType":null}}},{"name":"shippingmethods","description":null,"args":[{"name":"programId","description":null,"defaultValue":null,"type":{"name":null,"kind":"NON_NULL","description":null,"enumValues":null,"interfaces":null,"ofType":{"name":"Int","kind":"SCALAR","description":"The`Int`scalartyperepresentsnon-fractionalsignedwholenumericvalues.Intcanrepresentvaluesbetween-(2^31)and2^31-1.","enumValues":null,"interfaces":null,"ofType":null}}}],"type":{"name":null,"kind":"NON_NULL","description":null,"enumValues":null,"interfaces":null,"ofType":{"name":null,"kind":"LIST","description":null,"enumValues":null,"interfaces":null,"ofType":{"name":null,"kind":"NON_NULL","description":null,"enumValues":null,"interfaces":null,"ofType":{"name":"ShippingMethod","kind":"OBJECT","description":null,"enumValues":null,"interfaces":[],"ofType":null}}}}},{"name":"users","description":null,"args":[{"name":"ids","description":null,"defaultValue":null,"type":{"name":null,"kind":"LIST","description":null,"enumValues":null,"interfaces":null,"ofType":{"name":null,"kind":"NON_NULL","description":null,"enumValues":null,"interfaces":null,"ofType":{"name":"ID","kind":"SCALAR","description":"The`ID`scalartyperepresentsauniqueidentifier,oftenusedtorefetchanobjectoraskeyforacache.TheIDtypeappearsinaJSONresponseasaString;however,itisnotintendedtobehuman-readable.Whenexpectedasaninputtype,anystring(suchas`\\"4\\"`)orinteger(suchas`4`)inputvaluewillbeacceptedasanID.","enumValues":null,"interfaces":null,"ofType":null}}}},{"name":"names","description":null,"defaultValue":null,"type":{"name":null,"kind":"LIST","description":null,"enumValues":null,"interfaces":null,"ofType":{"name":null,"kind":"NON_NULL","description":null,"enumValues":null,"interfaces":null,"ofType":{"name":"String","kind":"SCALAR","description":"The`String`scalartyperepresentstextualdata,representedasUTF-8charactersequences.TheStringtypeismostoftenusedbyGraphQLtorepresentfree-formhuman-readabletext.","enumValues":null,"interfaces":null,"ofType":null}}}},{"name":"limit","description":null,"defaultValue":null,"type":{"name":"Limit","kind":"INPUT_OBJECT","description":null,"enumValues":null,"interfaces":null,"ofType":null}}],"type":{"name":null,"kind":"NON_NULL","description":null,"enumValues":null,"interfaces":null,"ofType":{"name":"Users","kind":"OBJECT","description":null,"enumValues":null,"interfaces":[{"name":"Pageable","kind":"INTERFACE","description":null}],"ofType":null}}}]},"mutationType":{"name":"Mutation","kind":"OBJECT","description":null,"enumValues":null,"interfaces":[],"fields":[{"name":"addressSearch","description":null,"args":[{"name":"session","description":null,"defaultValue":null,"type":{"name":null,"kind":"NON_NULL","description":null,"enumValues":null,"interfaces":null,"ofType":{"name":"ID","kind":"SCALAR","description":"The`ID`scalartyperepresentsauniqueidentifier,oftenusedtorefetchanobjectoraskeyforacache.TheIDtypeappearsinaJSONresponseasaString;however,itisnotintendedtobehuman-readable.Whenexpectedasaninputtype,anystring(suchas`\\"4\\"`)orinteger(suchas`4`)inputvaluewillbeacceptedasanID.","enumValues":null,"interfaces":null,"ofType":null}}},{"name":"address","description":null,"defaultValue":null,"type":{"name":null,"kind":"NON_NULL","description":null,"enumValues":null,"interfaces":null,"ofType":{"name":"String","kind":"SCALAR","description":"The`String`scalartyperepresentstextualdata,representedasUTF-8charactersequences.TheStringtypeismostoftenusedbyGraphQLtorepresentfree-formhuman-readabletext.","enumValues":null,"interfaces":null,"ofType":null}}}],"type":{"name":"Boolean","kind":"SCALAR","description":"The`Boolean`scalartyperepresents`true`or`false`.","enumValues":null,"interfaces":null,"ofType":null}},{"name":"createCharity","description":null,"args":[{"name":"charity","description":null,"defaultValue":null,"type":{"name":null,"kind":"NON_NULL","description":null,"enumValues":null,"interfaces":null,"ofType":{"name":"CreateCharity","kind":"INPUT_OBJECT","description":null,"enumValues":null,"interfaces":null,"ofType":null}}}],"type":{"name":null,"kind":"NON_NULL","description":null,"enumValues":null,"interfaces":null,"ofType":{"name":"Charity","kind":"OBJECT","description":null,"enumValues":null,"interfaces":[],"ofType":null}}},{"name":"createCharities","description":null,"args":[{"name":"charities","description":null,"defaultValue":null,"type":{"name":null,"kind":"NON_NULL","description":null,"enumValues":null,"interfaces":null,"ofType":{"name":null,"kind":"LIST","description":null,"enumValues":null,"interfaces":null,"ofType":{"name":null,"kind":"NON_NULL","description":null,"enumValues":null,"interfaces":null,"ofType":{"name":"CreateCharity","kind":"INPUT_OBJECT","description":null,"enumValues":null,"interfaces":null,"ofType":null}}}}}],"type":{"name":null,"kind":"NON_NULL","description":null,"enumValues":null,"interfaces":null,"ofType":{"name":null,"kind":"LIST","description":null,"enumValues":null,"interfaces":null,"ofType":{"name":null,"kind":"NON_NULL","description":null,"enumValues":null,"interfaces":null,"ofType":{"name":"BulkCreateCharityResponse","kind":"OBJECT","description":null,"enumValues":null,"interfaces":[],"ofType":null}}}}},{"name":"createGrant","description":null,"args":[{"name":"grant","description":null,"defaultValue":null,"type":{"name":null,"kind":"NON_NULL","description":null,"enumValues":null,"interfaces":null,"ofType":{"name":"CreateGrant","kind":"INPUT_OBJECT","description":null,"enumValues":null,"interfaces":null,"ofType":null}}}],"type":{"name":null,"kind":"NON_NULL","description":null,"enumValues":null,"interfaces":null,"ofType":{"name":"Grant","kind":"OBJECT","description":null,"enumValues":null,"interfaces":[],"ofType":null}}}]}}}}';

	// sample API response when fetching a single "full" type node for the 'Accounts' object, which is paginated
	private static final String SAMPLE_FULL_TYPE_RESPONSE_ACCOUNTS = '{"data":{"__type":{"name":"Accounts","kind":"OBJECT","description":null,"enumValues":null,"interfaces":[{"name":"Pageable","kind":"INTERFACE","description":null,"enumValues":null,"interfaces":[]}],"fields":[{"name":"pages","description":null,"type":{"name":null,"kind":"NON_NULL","description":null,"enumValues":null,"interfaces":null,"ofType":{"name":null,"kind":"LIST","description":null,"enumValues":null,"interfaces":null,"fields":null,"ofType":{"name":null,"kind":"NON_NULL","description":null,"enumValues":null,"interfaces":null,"fields":null,"ofType":{"name":"Account","kind":"OBJECT","description":null,"enumValues":null,"interfaces":[],"fields":[{"name":"amountRequiringBoardApprovals","description":null,"type":{"name":null,"kind":"NON_NULL","description":null,"enumValues":null,"interfaces":null,"ofType":{"name":"Decimal","kind":"SCALAR","description":"The built-in \\u0060Decimal\\u0060 scalar type.","enumValues":null,"interfaces":null,"ofType":null}}},{"name":"balance","description":null,"type":{"name":"Balance","kind":"OBJECT","description":null,"enumValues":null,"interfaces":[],"ofType":null}},{"name":"boardApprovalRequired","description":null,"type":{"name":null,"kind":"NON_NULL","description":null,"enumValues":null,"interfaces":null,"ofType":{"name":"Boolean","kind":"SCALAR","description":"The \\u0060Boolean\\u0060 scalar type represents \\u0060true\\u0060 or \\u0060false\\u0060.","enumValues":null,"interfaces":null,"ofType":null}}},{"name":"closedDate","description":null,"type":{"name":"DateTime","kind":"SCALAR","description":"The \\u0060DateTime\\u0060 scalar represents an ISO-8601 compliant date time type.","enumValues":null,"interfaces":null,"ofType":null}},{"name":"code","description":null,"type":{"name":null,"kind":"NON_NULL","description":null,"enumValues":null,"interfaces":null,"ofType":{"name":"String","kind":"SCALAR","description":"The \\u0060String\\u0060 scalar type represents textual data, represented as UTF-8 character sequences. The String type is most often used by GraphQL to represent free-form human-readable text.","enumValues":null,"interfaces":null,"ofType":null}}},{"name":"externalId","description":null,"type":{"name":null,"kind":"NON_NULL","description":null,"enumValues":null,"interfaces":null,"ofType":{"name":"ID","kind":"SCALAR","description":"The \\u0060ID\\u0060 scalar type represents a unique identifier, often used to refetch an object or as key for a cache. The ID type appears in a JSON response as a String; however, it is not intended to be human-readable. When expected as an input type, any string (such as \\u0060\\u00224\\u0022\\u0060) or integer (such as \\u00604\\u0060) input value will be accepted as an ID.","enumValues":null,"interfaces":null,"ofType":null}}},{"name":"grants","description":null,"type":{"name":null,"kind":"LIST","description":null,"enumValues":null,"interfaces":null,"ofType":{"name":null,"kind":"NON_NULL","description":null,"enumValues":null,"interfaces":null,"ofType":{"name":"Grant","kind":"OBJECT","description":null,"enumValues":null,"interfaces":[],"ofType":null}}}},{"name":"id","description":null,"type":{"name":null,"kind":"NON_NULL","description":null,"enumValues":null,"interfaces":null,"ofType":{"name":"ID","kind":"SCALAR","description":"The \\u0060ID\\u0060 scalar type represents a unique identifier, often used to refetch an object or as key for a cache. The ID type appears in a JSON response as a String; however, it is not intended to be human-readable. When expected as an input type, any string (such as \\u0060\\u00224\\u0022\\u0060) or integer (such as \\u00604\\u0060) input value will be accepted as an ID.","enumValues":null,"interfaces":null,"ofType":null}}},{"name":"name","description":null,"type":{"name":null,"kind":"NON_NULL","description":null,"enumValues":null,"interfaces":null,"ofType":{"name":"String","kind":"SCALAR","description":"The \\u0060String\\u0060 scalar type represents textual data, represented as UTF-8 character sequences. The String type is most often used by GraphQL to represent free-form human-readable text.","enumValues":null,"interfaces":null,"ofType":null}}},{"name":"openedDate","description":null,"type":{"name":"DateTime","kind":"SCALAR","description":"The \\u0060DateTime\\u0060 scalar represents an ISO-8601 compliant date time type.","enumValues":null,"interfaces":null,"ofType":null}},{"name":"otherPayments","description":null,"type":{"name":null,"kind":"NON_NULL","description":null,"enumValues":null,"interfaces":null,"ofType":{"name":"OtherPayments","kind":"OBJECT","description":null,"enumValues":null,"interfaces":[{"name":"Pageable","kind":"INTERFACE","description":null}],"ofType":null}}},{"name":"program","description":null,"type":{"name":null,"kind":"NON_NULL","description":null,"enumValues":null,"interfaces":null,"ofType":{"name":"Program","kind":"OBJECT","description":null,"enumValues":null,"interfaces":[],"ofType":null}}},{"name":"roles","description":null,"type":{"name":null,"kind":"NON_NULL","description":null,"enumValues":null,"interfaces":null,"ofType":{"name":"AccountRoles","kind":"OBJECT","description":null,"enumValues":null,"interfaces":[{"name":"Pageable","kind":"INTERFACE","description":null}],"ofType":null}}},{"name":"status","description":null,"type":{"name":null,"kind":"NON_NULL","description":null,"enumValues":null,"interfaces":null,"ofType":{"name":"AccountStatus","kind":"ENUM","description":null,"enumValues":[{"name":"CLOSED"},{"name":"OPEN"},{"name":"PENDING"}],"interfaces":null,"ofType":null}}},{"name":"subtype","description":null,"type":{"name":null,"kind":"NON_NULL","description":null,"enumValues":null,"interfaces":null,"ofType":{"name":"AccountSubtype","kind":"ENUM","description":null,"enumValues":[{"name":"CGA"},{"name":"CRAT"},{"name":"DAF"},{"name":"DCGA"},{"name":"FDGCA"},{"name":"FLIP"},{"name":"GCLAT"},{"name":"GCLUT"},{"name":"GSLUT"},{"name":"ILIT"},{"name":"MPIF"},{"name":"NA"},{"name":"NCLAT"},{"name":"NCLUT"},{"name":"NICRUT"},{"name":"NIMCRUT"},{"name":"PF"},{"name":"PIF"},{"name":"SCLAT"},{"name":"SCLUT"},{"name":"SCRUT"},{"name":"SNT"},{"name":"TAX"}],"interfaces":null,"ofType":null}}},{"name":"type","description":null,"type":{"name":null,"kind":"NON_NULL","description":null,"enumValues":null,"interfaces":null,"ofType":{"name":"AccountType","kind":"ENUM","description":null,"enumValues":[{"name":"CGA"},{"name":"CLT"},{"name":"CRT"},{"name":"DAF"},{"name":"EDAF"},{"name":"ILIT"},{"name":"NA"},{"name":"PF"},{"name":"PIF"},{"name":"TAX"}],"interfaces":null,"ofType":null}}}],"ofType":null}}}}},{"name":"pagination","description":null,"type":{"name":null,"kind":"NON_NULL","description":null,"enumValues":null,"interfaces":null,"ofType":{"name":"Pagination","kind":"OBJECT","description":null,"enumValues":null,"interfaces":[],"fields":[{"name":"items","description":null,"type":{"name":"Int","kind":"SCALAR","description":"The \\u0060Int\\u0060 scalar type represents non-fractional signed whole numeric values. Int can represent values between -(2^31) and 2^31 - 1.","enumValues":null,"interfaces":null,"ofType":null}},{"name":"next","description":null,"type":{"name":"Boolean","kind":"SCALAR","description":"The \\u0060Boolean\\u0060 scalar type represents \\u0060true\\u0060 or \\u0060false\\u0060.","enumValues":null,"interfaces":null,"ofType":null}},{"name":"previous","description":null,"type":{"name":"Boolean","kind":"SCALAR","description":"The \\u0060Boolean\\u0060 scalar type represents \\u0060true\\u0060 or \\u0060false\\u0060.","enumValues":null,"interfaces":null,"ofType":null}},{"name":"total","description":null,"type":{"name":"Int","kind":"SCALAR","description":"The \\u0060Int\\u0060 scalar type represents non-fractional signed whole numeric values. Int can represent values between -(2^31) and 2^31 - 1.","enumValues":null,"interfaces":null,"ofType":null}}],"ofType":null}}}]}}}';

	// sample API response when fetching a single "full" type node for the 'Acknowledgement' object, which is not paginated
	private static final String SAMPLE_FULL_TYPE_RESPONSE_ACKNOWLEDGEMENTS = '{"data":{"__type":{"name":"Acknowledgement","kind":"OBJECT","description":null,"enumValues":null,"interfaces":[],"fields":[{"name":"description","description":null,"type":{"name":"String","kind":"SCALAR","description":"The \\u0060String\\u0060 scalar type represents textual data, represented as UTF-8 character sequences. The String type is most often used by GraphQL to represent free-form human-readable text.","enumValues":null,"interfaces":null,"ofType":null}},{"name":"id","description":null,"type":{"name":null,"kind":"NON_NULL","description":null,"enumValues":null,"interfaces":null,"ofType":{"name":"Int","kind":"SCALAR","description":"The \\u0060Int\\u0060 scalar type represents non-fractional signed whole numeric values. Int can represent values between -(2^31) and 2^31 - 1.","enumValues":null,"interfaces":null,"fields":null,"ofType":null}}}]}}}';

	// sample API response when fetching a single "full" type node for the 'Balance' object
	private static final String SAMPLE_FULL_TYPE_RESPONSE_BALANCE = '{"data":{"__type":{"name":"Balance","kind":"OBJECT","description":null,"enumValues":null,"interfaces":[],"fields":[{"name":"accountId","description":null,"type":{"name":null,"kind":"NON_NULL","description":null,"enumValues":null,"interfaces":null,"ofType":{"name":"ID","kind":"SCALAR","description":"The \\u0060ID\\u0060 scalar type represents a unique identifier, often used to refetch an object or as key for a cache. The ID type appears in a JSON response as a String; however, it is not intended to be human-readable. When expected as an input type, any string (such as \\u0060\\u00224\\u0022\\u0060) or integer (such as \\u00604\\u0060) input value will be accepted as an ID.","enumValues":null,"interfaces":null,"fields":null,"ofType":null}}},{"name":"actual","description":null,"type":{"name":null,"kind":"NON_NULL","description":null,"enumValues":null,"interfaces":null,"ofType":{"name":"Decimal","kind":"SCALAR","description":"The built-in \\u0060Decimal\\u0060 scalar type.","enumValues":null,"interfaces":null,"fields":null,"ofType":null}}},{"name":"actualEffectiveDate","description":null,"type":{"name":null,"kind":"NON_NULL","description":null,"enumValues":null,"interfaces":null,"ofType":{"name":"DateTime","kind":"SCALAR","description":"The \\u0060DateTime\\u0060 scalar represents an ISO-8601 compliant date time type.","enumValues":null,"interfaces":null,"fields":null,"ofType":null}}},{"name":"available","description":null,"type":{"name":null,"kind":"NON_NULL","description":null,"enumValues":null,"interfaces":null,"ofType":{"name":"Decimal","kind":"SCALAR","description":"The built-in \\u0060Decimal\\u0060 scalar type.","enumValues":null,"interfaces":null,"fields":null,"ofType":null}}},{"name":"pending","description":null,"type":{"name":null,"kind":"NON_NULL","description":null,"enumValues":null,"interfaces":null,"ofType":{"name":"Decimal","kind":"SCALAR","description":"The built-in \\u0060Decimal\\u0060 scalar type.","enumValues":null,"interfaces":null,"fields":null,"ofType":null}}}]}}}';

	// sample API response when fetching one record and there are no records to fetch
	private static final String SAMPLE_ACCOUNTS_RECORD_FETCH_NO_RECORDS = '{"data":{"accounts":{"pages":[{"name":"Acme"}],"pagination":{"items":0,"total":0,"next":false,"previous":false}}}}';

	// sample API response when fetching one record and there are no more records to fetch
	private static final String SAMPLE_ACCOUNTS_RECORD_FETCH_ALL_RECORDS = '{"data":{"accounts":{"pages":[{"name":"Acme"}],"pagination":{"items":1,"total":1,"next":false,"previous":false}}}}';

	// sample API response when fetching one record and there are more records to fetch
	private static final String SAMPLE_ACCOUNTS_RECORD_FETCH_RECORDS_MORE_LEFT = '{"data":{"accounts":{"pages":[{"name":"Acme"}],"pagination":{"items":1,"total":30,"next":true,"previous":false}}}}';

	// sample API response when fetching one record and there are no more records to fetch
	private static final String SAMPLE_ACKNOWLEDGEMENTS_RECORD_FETCH_ALL_RECORDS = '{"data":{"acknowledgements":[{"id":123,"description":"Sample"}]}}';

	// sample API response when fetching records with partial failure
	private static final String SAMPLE_ACCOUNTS_RECORD_FETCH_PARTIAL_ERRORS = '{"errors":[{"message":"HttpRequestException","path":["accounts","pages",1,"balance"],"extensions":{"details":"Failed to fetch account balance"}}],"data":{"accounts":{"pages":[{"name":"Acme","balance":1200.0},{"name":"Baker","balance":null}],"pagination":{"items":2,"total":2,"next":false,"previous":false}}}}';
}