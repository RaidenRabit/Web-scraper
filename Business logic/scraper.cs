using Business_logic.Models;
using Newtonsoft.Json.Linq;
using System.Collections.Generic;
using System.IO;

namespace Business_logic
{
    public class Scraper
    {
        ApiCaller _apiCaller;

        public Scraper()
        {
            _apiCaller = new ApiCaller();
        }

        public List<DeliveryDays> GetCleanData(string postalCode, string year = "null", string month = "null")
        {
            string originalData = _apiCaller.CallApi(postalCode, year, month).Result;

            JObject jo = JObject.Parse(originalData);
            var header = jo.SelectToken("model.days");
            if (header != null)
            {
                var deliveryDays = header.ToObject<List<DeliveryDays>>();
                deliveryDays.RemoveAll(x => x.slots == null);
                deliveryDays.RemoveAll(x => x.slots.Count < 1);
                foreach (var i in deliveryDays)
                {
                    i.zipCode = postalCode;
                }

                return deliveryDays;
            }
            return null;
        }

        public List<string> GetZipCodes()
        {
            ExcelReader e = new ExcelReader();
            return e.ReadExcel(new MemoryStream(Properties.Resources.Danish_ZIPs));
        }

    }
}
