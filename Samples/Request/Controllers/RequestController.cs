using Microsoft.AspNetCore.Mvc;
using Dapr.Client;

namespace Request.Controllers;

[ApiController]
[Route("api")]
public class RequestController : ControllerBase
{
    private readonly ILogger<RequestController> _logger;
    DaprClient daprClient;
    private const string storeName = "uploadblobapp";

    public RequestController(ILogger<RequestController> logger)
    {
        _logger = logger;
        daprClient = new DaprClientBuilder().Build();
    }

    [HttpPost]
	[Route("add/{filename}")]
	public async Task Add([FromBody] string image, [FromRoute] string filename)
    {
		_logger.LogInformation("Image is trying to upload");
		//Upload file
		var metadataDictionary = new Dictionary<string, string>()
        {
            { "blobName", filename },
        };

        await daprClient.InvokeBindingAsync(storeName, "create", image, metadataDictionary);
		_logger.LogInformation("File is uploaded - " + filename);
	}

    [HttpGet]
    public IActionResult HealthCheck() => Ok();

/*
    [HttpPost]
	[Route("upload/{filename}")]
    public async Task UploadImage(string file, string filename)
        {
            BlobServiceClient blobServiceClient = new BlobServiceClient(Environment.GetEnvironmentVariable("AZURE_STORAGE_CONNECTION_STRING")); 
            BlobContainerClient containerClient = blobServiceClient.GetBlobContainerClient("objects");
            BlobClient blobClient = containerClient.GetBlobClient(filename);

            var decodedImage = Convert.FromBase64String(file);
            using (var fileStream = new MemoryStream(decodedImage))
            {
                // upload image stream to blob
                await blobClient.UploadAsync(fileStream, true);
            }
        }
*/

}
