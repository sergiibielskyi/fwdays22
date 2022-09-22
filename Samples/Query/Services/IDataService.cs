using Microsoft.Azure.Cosmos;

namespace Query
{
    public interface IDataService
    {
        Task<List<dynamic>> GetAllData(string databaseId, string containerId, CosmosClient dbClient, string country);
    }
}