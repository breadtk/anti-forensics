#!/usr/bin/env python
#
# Author: Osman Surkatty (osman@surkatty.org)
#
# A simple script which can be used to periodically clean out your Twitter
# timeline.

from datetime import *
from twitter import *
import sys
import time

def lambda_handler(event, context):
    older_than = 30 # days

    # From: https://apps.twitter.com/ or https://developer.twitter.com/
    token = ""
    token_key = ""
    con_secret = ""
    con_secret_key = ""

    t = Twitter(auth=OAuth(token, token_key, con_secret, con_secret_key))

    favorites = t.favorites.list(count=200)
    tweets = t.statuses.user_timeline(count=200)

    deleted_tweets = 0
    unfavorited_tweets = 0

    while True:
        if favorites:
            fav = favorites.pop()

            days_ago = (datetime.today() -
                        datetime.strptime(fav['created_at'], "%a %b %d %H:%M:%S +0000 %Y")).days

            if days_ago > older_than:
                print("[*] Unfavoriting tweet..")
                t.favorites.destroy(_id=fav['id'])
                unfavorited_tweets += 1

        if tweets:
            tweet = tweets.pop()

            days_ago = (datetime.today() -
                        datetime.strptime(tweet['created_at'], "%a %b %d %H:%M:%S +0000 %Y")).days

            if days_ago > older_than:
                print("[*] Deleting tweet..")
                t.statuses.destroy(_id=tweet['id'])
                deleted_tweets += 1

        if not favorites and not tweets:
            break

    print("[*] Deleted " + str(deleted_tweets) + " tweets and unfavorited " +
          str(unfavorited_tweets) + " tweets.")
