# 爬虫
import requests
import html
from lxml import etree
import re
import time
import csv

def get_html(index, page):
    url = f'https://www.dongchedi.com/auto/series/score/{index}-x-S0-x-x-x-{page}'
    r = requests.get(url)
    r = html.unescape(r.text)
    return r

# Implement
from itertools import repeat
with open('whole_review.csv', 'a+', newline='',encoding='utf-8-sig') as f:
    csv_write = csv.writer(f)
    columns = ["Brand","Series","CarName","Review","Rate","外观","内饰","配置","空间","舒适性","操控","动力"]
    csv_write.writerow(columns)
f.close()
for index in range(5226,6000):
    print("正在爬取第" + str(index) + "款车型")
    page = 1
    for _ in repeat(None):
        raw_html = get_html(index, page)
        t_html = etree.HTML(raw_html)
        car_name = t_html.xpath('.//span[@class="tw-ml-4 tw-font-bold tw-text-16"]')
        car_review = t_html.xpath('.//p[@class="line-4 tw-text-16 tw-leading-26 tw-cursor-pointer"]')
        car_rate = t_html.xpath('.//span[@class="tw-relative"]')
        car_detailed_rate = t_html.xpath('.//p[@class="styles_score-item__2KcxU"]')
        brand_name = t_html.xpath('.//span[@class="pos-item icon icon-arrow-ic-r"]/a[@target="_blank"]')

        if(len(car_name) == 0):
            break
        print("正在爬取第" + str(index) + "款车型的第" + str(page) + "页")
        if((len(car_name) == len(car_review) == ((len(car_rate) - 1) / 2) == (len(car_detailed_rate) / 8)) and len(brand_name) == 2):
            with open('whole_review.csv', 'a+', newline='',encoding='utf-8-sig') as f:
                for i in range(len(car_name)):
                    csv_write = csv.writer(f)
                    data_row = [brand_name[0].text, brand_name[1].text, car_name[i].text.replace("\n","").lstrip(), car_review[i].text.replace("\n",""), car_rate[i * 2 + 2].text]
                    for j in range(1, 8):
                        data_row.append(car_detailed_rate[i * 8 + j].text)
                    csv_write.writerow(data_row)
            f.close()
        page = page + 1