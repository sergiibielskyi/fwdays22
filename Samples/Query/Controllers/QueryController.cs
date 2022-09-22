using Dapr.Client;
using Microsoft.AspNetCore.Mvc;

namespace Query.Controllers;

[ApiController]
[Route("api")]
public class QueryController : ControllerBase
{
    
    private readonly ILogger<QueryController> _logger;
    private DaprClient daprClient;
    private const string storeName = "cosmosdb";

    public QueryController(ILogger<QueryController> logger)
    {
        daprClient = new DaprClientBuilder().Build();
        _logger = logger;
    }

    [HttpGet]
    public IActionResult HealthCheck() => Ok();

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
    [Route("objects/{id}")]
    public async Task<dynamic> GetById([FromRoute] string id)
    {
        return await daprClient.GetStateAsync<dynamic>(storeName, id);
    }
}
