/**
 * https://github.com/callawaycloud/apex-graphql-query
 * License: https://raw.githubusercontent.com/callawaycloud/apex-graphql-query/master/LICENSE
 */
public class GraphQLQuery {
	public String query;
	public Object variables;
	public GraphQLQuery(String query, Object variables){
		this.query = query;
		this.variables = variables;
	}

	public GraphQLQuery(GraphQLNode node, Object variables){
		this.query = buildQuery(node);
		this.variables = variables;
	}

	public GraphQLQuery(GraphQLNode[] nodes, Object variables){
		this.query = buildQuery(nodes);
		this.variables = variables;
	}

	private static String buildQuery(GraphQLNode node){
		if(node.operation != null){
			return node.build();
		}
		return '{\n' + node.build() + '\n}';
	}

	private static String buildQuery(GraphQLNode[] nodes){
		String[] nodeStrings = new String[]{};
		for(GraphQLNode node : nodes){
			nodeStrings.add(node.build());
		}
		return '{\n' + String.join(nodeStrings, '\n') + '\n}';
	}
}