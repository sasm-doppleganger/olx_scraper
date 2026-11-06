from config import (DEFAULT_LIMIT, DEFAULT_CATEGORY_ID, SUGGEST_FILTERS, SL,
                    QUERY, SEARCH_QUERY, URL, HEADERS)
import requests
import pandas as pd
import time
import logging
from datetime import datetime
from pathlib import Path

TODAY = datetime.now().strftime("%Y-%m-%d")
PROJECT_ROOT = Path.cwd()


log_dir = PROJECT_ROOT / "logs" / "local_scraper"
log_dir.mkdir(exist_ok=True)
log_file = log_dir / f"scraper_{TODAY}.log"

logging.basicConfig(
    level=logging.INFO,
    format="%(asctime)s [%(levelname)s] %(message)s",
    handlers=[logging.FileHandler(log_file),
              logging.StreamHandler()],
    force=True
)

logger = logging.getLogger(__name__)


def build_variables(
      query,
      offset=0,
      limit=DEFAULT_LIMIT,
      category_id=DEFAULT_CATEGORY_ID,
      suggest_filters=SUGGEST_FILTERS,
      sl=SL
      ) -> dict: 
   
   return {
    "searchParameters": [
        {"key": "offset", "value": str(offset)},
        {"key": "limit", "value": str(limit)},
        {"key": "query", "value": str(query)},
        {"key": "category_id", "value":str(category_id)},
        {"key": "suggest_filters", "value": suggest_filters},
        {"key": "sl", "value": sl}
    ]
   }

def parse_listing(ad) -> dict:
    row = {}

    # identity
    row["id"] = ad.get("id")
    row["created_time"] = ad.get("created_time")
    row["valid_to_time"] = ad.get("valid_to_time")
    row["title"] = ad.get("title")
    row["status"] = ad.get("status")
    row["url"] = ad.get("url")
    row["description"] = ad.get("description")

    # location
    def get_location(ad: dict, i: str) -> str:
      if ad.get("location").get(i):
        return ad.get("location").get(i).get("name")
      return "null"

    row["city"] = get_location(ad, "city")
    row["district"] = get_location(ad, "district")
    row["region"] = get_location(ad, "region")

    # price
    price_param = next(
      (p for p in ad["params"] if p["key"] == "price"),
      None).get("value")

    row["price_org"] = price_param.get("value")
    row["currency_org"] = price_param.get("currency")
    if price_param.get("currency") == "UAH":
      row["price_uah"] = price_param.get("value")
    else:
      row["price_uah"] = price_param.get("converted_value")


    #
    for p in ad["params"]:
      # commision, copperate(with rieltors), joint lease
      # comission 1 equals to "no_comission"
      if p["type"] == "checkbox":
        name = p.get("key")
        value_key = p.get("value").get("key")
        value_label = p.get("value").get("label")
        row[f"{name}_key"] = value_key
        row[f"{name}_label"] = value_label

      # property_type_appartments_sale, house_type,
      # number_of_rooms_string, layout, bathroom,
      # heating, repair, furnish
      elif p["type"] == "select":
        name = p.get("key")
        value_key = p.get("value").get("key")
        value_label = p.get("value").get("label")

        row[f"{name}_key"] = value_key
        row[f"{name}_label"] = value_label

      # floor, year_of_commissioning, total_floors
      # total_area, kitchen_area
      elif p["type"] == "input":
        name = p.get("key")
        value_key = p.get("value").get("key")
        value_label = p.get("value").get("label")

        row[f"{name}_key"] = value_key
        row[f"{name}_label"] = value_label

      # pets, appliances_2, multimedia_2, comfort,
      # communications, infrastructure_500_m
      # ecosystem_1_km
      elif p["type"] == "checkboxes":
        main_name = p.get("key")
        values = p.get("value").get("checkboxParamKey", [])
        for v in values:
          row[f"{main_name}_{v}"] = 1

    return row

def scrape_listings():
  all_rows = []
  seen_ids= set()


  offset = 0


  total_count = -1 # -1 to account for headers row


  while True:
    PAYLOAD = {
        "query": QUERY,
        "variables": build_variables(
           query=SEARCH_QUERY,
           offset=offset
        )
    }
    

    try:
        res = requests.post(url=URL, json=PAYLOAD, headers=HEADERS)
        status_code = res.status_code
        if status_code != 200:
          raise ValueError(f"{status_code}")
    except ValueError as e:
      logger.error(f"Bad response: {e}")
      break
    

    logger.info(f"Fetching offset: {offset}")


    data = res.json()
    listings = data.get("data", {}) \
                  .get("clientCompatibleListings", {}) \
                  .get("data", [])


    if not listings:
        logger.info("No more listings. Stopping.")
        break

    new_count = 0

    for ad in listings:
        ad_id = ad.get("id")

        if ad_id in seen_ids:
            continue
        
        seen_ids.add(ad_id)

        row = parse_listing(ad)
        all_rows.append(row)

        new_count += 1

    total_count += new_count

    logger.info(f"Added {new_count} new listings")

    if new_count == 0:
        logger.warning("No new data detected. Stopping.")
        break

    offset += DEFAULT_LIMIT
    time.sleep(1)

  logger.info(f"Scraped all listings, {total_count} in total.")  
  return all_rows

def save_listings(all_rows):
  # today = "2026-06-26"

  df = pd.DataFrame(all_rows)
  df['scraped_at'] = TODAY

  # filename = "listings_yyyymmdd_hhmmss.parquet"
  filename = f"listings_{datetime.now():%Y%m%d_%H%M%S}.parquet"
  
  output_dir = PROJECT_ROOT / "raw_bucket" / f"{TODAY}"
  output_dir.mkdir(exist_ok=True)

  output_path = output_dir / filename

  df.to_parquet(output_path, index=False)


  logger.info(f"Upload to bucket complete -> {output_path}")   

def main():
   save_listings(scrape_listings())


if __name__ == "__main__":
   main()