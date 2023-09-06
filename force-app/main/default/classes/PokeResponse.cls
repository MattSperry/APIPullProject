public class PokeResponse {
  public List<Result> results { get; set; }
  public class Result {
    public String name { get; set; }
    public String url { get; set; }
  }
}
