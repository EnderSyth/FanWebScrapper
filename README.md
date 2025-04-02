# FanWebScrapper

Just some code for web scrapping that I've made for Ao3 and FFN via [WebScrapper Addon](https://webscraper.io/) to grab all of a works comments and stores it into a csv.

Ao3: The url to use here is the /comments page of a work. First find the works main url (not chapter) such as https://archiveofourown.org/works/**** then add /comments to the end like this https://archiveofourown.org/works/****/comments. The built in pagination will capture all pages automatically.
```{"_id":"Ao3-****","startUrl":["https://archiveofourown.org/works/****/comments"],"selectors":[{"id":"DisplayComments","parentSelectors":["_root"],"type":"SelectorElementClick","clickActionType":"real","clickElementSelector":"#show_comments_link a","clickElementUniquenessType":"uniqueText","clickType":"clickOnce","delay":2000,"discardInitialElements":"do-not-discard","multiple":false,"selector":"div.feedback"},{"id":"Pagination","parentSelectors":["DisplayComments","Pagination"],"paginationType":"clickMore","type":"SelectorPagination","selector":"ol:nth-of-type(1) .next a"},{"id":"PageComments","parentSelectors":["Pagination"],"type":"SelectorElement","selector":"#comments_placeholder > ol.thread","multiple":true},{"id":"Comment Blocks","parentSelectors":["PageComments"],"type":"SelectorElement","selector":"> li","multiple":true},{"id":"Comment Body","parentSelectors":["Comment Blocks"],"type":"SelectorText","selector":"blockquote","multiple":false,"regex":""},{"id":"Chapter","parentSelectors":["Comment Blocks"],"type":"SelectorText","selector":"span.parent","multiple":false,"regex":""},{"id":"User","parentSelectors":["Comment Blocks"],"type":"SelectorText","selector":".heading a","multiple":false,"regex":""}]}```


FFN: The URL to use here is the review page /r/ of a story. You'll want to stay on all chapters then select the last option. This will give you the final page number which is needed for the URL. You can put the page range inside square brackets to tell it to load each page. For instance ```"https://www.fanfiction.net/r/****/0/[1-8]"``` loads pages 1-8 of the reviews (/0/ is all chapters). 
```{"_id":"FF-****","startUrl":["https://www.fanfiction.net/r/****/0/[1-8]"],"selectors":[{"id":"CommentBlock","parentSelectors":["_root"],"type":"SelectorElement","selector":".table td","multiple":true},{"id":"User","parentSelectors":["CommentBlock"],"type":"SelectorText","selector":"> a","multiple":false,"regex":""},{"id":"Chapter","parentSelectors":["CommentBlock"],"type":"SelectorText","selector":"small","multiple":false,"regex":""},{"id":"Comment","parentSelectors":["CommentBlock"],"type":"SelectorText","selector":"div","multiple":false,"regex":""}]}```

Once you have the csv I've made a powershell script to convert the csv to a text file for easy processing with AI models. I use [https://aistudio.google.com/] Gemini 2.5 Pro Experimental as it has a million token context window which is needed to properly process a large amount of comments. 

The prompt I use is variants of this:

"I want you to analyze comments from a Fandom Fan Fiction called Title. I want you to analyze all of them and let me know what negative feedback is provided and on what chapters the most negative feedback is given and why. Make sure to include anything regarding toxicity in MainCharacter's romantic relationships. I will attach the comments as a text file once you confirm you understand what I'm asking."

This usually results in a solid response that lets me know what types of negative feedbacks and relationship issues I can exepct. 
