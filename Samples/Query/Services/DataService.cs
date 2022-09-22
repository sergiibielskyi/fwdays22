using Microsoft.Azure.Cosmos;

namespace Query
{
    public class DataService : IDataService
    {
        public async Task<List<dynamic>> GetAllData(string databaseId, string containerId, CosmosClient dbClient, string country)
        {
            QueryDefinition queryDefinition = new QueryDefinition("SELECT * FROM c WHERE c.Country = '" + country + "'");
            using FeedIterator<dynamic> queryResultSetIterator = dbClient.GetContainer(databaseId, containerId).GetItemQueryIterator<dynamic>(queryDefinition);
            List<dynamic> objects = new List<dynamic>();

            while (queryResultSetIterator.HasMoreResults)
            {
                FeedResponse<dynamic> currentResultSet = await queryResultSetIterator.ReadNextAsync();
                foreach (var obj in currentResultSet)
                    objects.Add(obj);
            }
            
            return objects;
        }
    }
}