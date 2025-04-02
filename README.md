# FanWebScrapper

Just some code for web scrapping that I've made for Ao3 and FFN via WebScrapper Firefox Addon.

Ao3:  
```{"_id":"Ao3-Blindness","startUrl":["https://archiveofourown.org/works/41852619/comments"],"selectors":[{"id":"DisplayComments","parentSelectors":["_root"],"type":"SelectorElementClick","clickActionType":"real","clickElementSelector":"#show_comments_link a","clickElementUniquenessType":"uniqueText","clickType":"clickOnce","delay":2000,"discardInitialElements":"do-not-discard","multiple":false,"selector":"div.feedback"},{"id":"Pagination","parentSelectors":["DisplayComments","Pagination"],"paginationType":"clickMore","type":"SelectorPagination","selector":"ol:nth-of-type(1) .next a"},{"id":"PageComments","parentSelectors":["Pagination"],"type":"SelectorElement","selector":"#comments_placeholder > ol.thread","multiple":true},{"id":"Comment Blocks","parentSelectors":["PageComments"],"type":"SelectorElement","selector":"> li","multiple":true},{"id":"Comment Body","parentSelectors":["Comment Blocks"],"type":"SelectorText","selector":"blockquote","multiple":false,"regex":""},{"id":"Chapter","parentSelectors":["Comment Blocks"],"type":"SelectorText","selector":"span.parent","multiple":false,"regex":""},{"id":"User","parentSelectors":["Comment Blocks"],"type":"SelectorText","selector":".heading a","multiple":false,"regex":""}]}```


FFN:  
```{"_id":"FF-Once-Again-With-Feeling","startUrl":["https://www.fanfiction.net/r/14350932/0/[1-8]"],"selectors":[{"id":"CommentBlock","parentSelectors":["_root"],"type":"SelectorElement","selector":".table td","multiple":true},{"id":"User","parentSelectors":["CommentBlock"],"type":"SelectorText","selector":"> a","multiple":false,"regex":""},{"id":"Chapter","parentSelectors":["CommentBlock"],"type":"SelectorText","selector":"small","multiple":false,"regex":""},{"id":"Comment","parentSelectors":["CommentBlock"],"type":"SelectorText","selector":"div","multiple":false,"regex":""}]}```
