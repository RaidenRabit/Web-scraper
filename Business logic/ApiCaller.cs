using System;
using System.Net.Http;
using System.Net.Http.Headers;
using System.Text;
using System.Threading.Tasks;

namespace Business_logic
{
    class ApiCaller
    {
        HttpClient _client;

        public ApiCaller()
        {
            _client = new HttpClient();
        }


        public async Task<string> CallApi(string postalCode, string year, string month)
        {
            try
            {
                using (var client = new HttpClient { Timeout = TimeSpan.FromSeconds(30) })
                {
                    string jsonBody = "{\"postalCode\":" + postalCode + ",\"cncDropPointId\":\"\",\"year\":" +
                        year + ",\"month\":" + month + ",\"deliveryFrom\":null,\"isMealKitEligible\":false," +
                        "\"isMealPlanSubscription\":false,\"hasMealKit\":false}";
                    client.DefaultRequestHeaders.Accept.Add(new MediaTypeWithQualityHeaderValue("application/json"));

                    var requestUri = new UriBuilder(new Uri("https://mad.coop.dk/api/delivery/loadmonth")).Uri;

                    HttpRequestMessage request = new HttpRequestMessage(HttpMethod.Post, requestUri);
                    request.Content = new StringContent(jsonBody, Encoding.UTF8, "application/json");

                    HttpResponseMessage response = await client.SendAsync(request);

                    return await response.Content.ReadAsStringAsync();
                };
            }catch(Exception e)
            {
                return "";
            }
        }
    }
}
