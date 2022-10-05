using Dapr.Client;
using Microsoft.AspNetCore.Mvc;
using Microsoft.Azure.Cosmos;
using Newtonsoft.Json;

namespace Query.Controllers;

[ApiController]
[Route("api")]
public class QueryController : ControllerBase
{
    
    private readonly ILogger<QueryController> _logger;
    private DaprClient daprClient;
    private const string storeName = "cosmosdbapp";
    private readonly string EndpointUri = "https://fwdaysaccount.documents.azure.com:443/";
    private readonly string PrimaryKey = "";
    private readonly string databaseId = "fwDaysDB";
    private readonly string containerId = "fwDaysContainer";
    private IDataService iDataService;

    private CosmosClient dbClient;

    public QueryController(ILogger<QueryController> logger, IDataService dataService)
    {
        daprClient = new DaprClientBuilder().Build();
        //dbClient = new CosmosClient(EndpointUri, PrimaryKey);
        iDataService = dataService;
        _logger = logger;
    }

    [HttpGet]
    public IActionResult HealthCheck()  
    {
         _logger.LogInformation("System is healthy");
        return Ok();
    }

    [HttpGet]
    [Route("objects/query")]
    public async Task<IActionResult> GetObjectsByQuery([FromHeader] string country)
    {
        CancellationTokenSource source = new CancellationTokenSource();
        CancellationToken cancellationToken = source.Token;
        
        var query = "{" +
                "\"filter\": {" +
                    "\"EQ\": { \"Country\": \""+ country +"\" }" +
                "}" +
            "}";
        
        var queryResponse =  await daprClient.QueryStateAsync<dynamic>(storeName, query, cancellationToken: cancellationToken);
         _logger.LogInformation(queryResponse.Results.Count.ToString());
        
        return StatusCode(200, queryResponse.Results);
    }

    [HttpGet]
    [Route("object/{id}")]
    public async Task<dynamic> GetById([FromRoute] string id)
    {
        return await daprClient.GetStateAsync<dynamic>(storeName, id);
    }

    //workaround using native cosmos db api sdk
    /*[HttpGet]
    [Route("objects/all")]
    public async Task<List<dynamic>> GetAll([FromHeader] string country)
    {
        List<dynamic> objects = await iDataService.GetAllData(databaseId, containerId, dbClient, country);
         _logger.LogInformation(objects.Count.ToString());

        return objects;
    }*/
}
