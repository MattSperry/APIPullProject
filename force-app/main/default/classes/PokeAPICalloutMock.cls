public class PokeAPICalloutMock implements HttpCalloutMock {
  public HTTPResponse respond(HTTPRequest req) {
    HttpResponse response = new HttpResponse();
    response.setHeader('Content-Type', 'application/json');

    // Simulate a successful or failed response based on the request URL
    if (req.getEndpoint().contains('nonexistent_pokemon')) {
      response.setBody('{"error": "Pokemon not found"}');
      response.setStatusCode(404); // Simulate a failed response
    } else {
      response.setBody('{"pokemon": {"PokeId__c":143, "name":"snorlax", "Account__c":"SOLVD"}}');
      response.setStatusCode(200); // Simulate a successful response
    }

    return response;
  }
}