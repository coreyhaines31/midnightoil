#!/usr/bin/env python3
"""Tells IndexNow search engines (Bing and others) about every URL in the sitemap.

    python3 site/_build/indexnow.py   # after deploying from main
"""
import json
import os
import re
import urllib.request

ROOT = os.path.join(os.path.dirname(__file__), "..")
KEY = "26bb231f9435485e036dbcd783d424cd"

with open(os.path.join(ROOT, "sitemap.xml")) as f:
    urls = re.findall(r"<loc>(.*?)</loc>", f.read())
body = json.dumps({"host": "midnightoil.app", "key": KEY,
                   "keyLocation": f"https://midnightoil.app/{KEY}.txt", "urlList": urls}).encode()
request = urllib.request.Request("https://api.indexnow.org/indexnow", data=body,
                                 headers={"Content-Type": "application/json; charset=utf-8"})
with urllib.request.urlopen(request) as response:
    print(f"IndexNow: {response.status} for {len(urls)} URLs")
