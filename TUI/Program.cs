using Business_logic;
using Business_logic.Models;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace TUI
{
    class Program
    {
        static void Main(string[] args)
        {
            List<List<DeliveryDays>> allZipDeliveries = new List<List<DeliveryDays>>();
            List<string> zipCodes;
            Scraper scraper = new Scraper();

            Console.WriteLine("Reading zip codes");

            ExcelReader e = new ExcelReader();
            zipCodes = scraper.GetZipCodes();

            Console.WriteLine("Getting data for each zip code and putting it in a db");

            for(int i = 0; i < zipCodes.Count - 1; i++)
            {
                DrawTextProgressBar(i, zipCodes.Count);
                var deliveries = scraper.GetCleanData(zipCodes[i]);
                allZipDeliveries.Add(deliveries);

            }
        }

        private static void DrawTextProgressBar(int progress, int total)
        {
            //draw empty progress bar
            Console.CursorLeft = 0;
            Console.Write("["); //start
            Console.CursorLeft = 32;
            Console.Write("]"); //end
            Console.CursorLeft = 1;
            float onechunk = 30.0f / total;

            //draw filled part
            int position = 1;
            for (int i = 0; i < onechunk * progress; i++)
            {
                Console.BackgroundColor = ConsoleColor.Gray;
                Console.CursorLeft = position++;
                Console.Write(" ");
            }

            //draw unfilled part
            for (int i = position; i <= 31; i++)
            {
                Console.BackgroundColor = ConsoleColor.Green;
                Console.CursorLeft = position++;
                Console.Write(" ");
            }

            //draw totals
            Console.CursorLeft = 35;
            Console.BackgroundColor = ConsoleColor.Black;
            Console.Write(progress.ToString() + " of " + total.ToString() + "    "); //blanks at the end remove any excess
        }
    }
}
