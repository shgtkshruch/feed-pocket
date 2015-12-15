feedURL = ''

google.load 'feeds', 1

initialize = ->
  feed = new google.feeds.Feed feedURL
  feed.setNumEntries 10
  feed.load (result) ->
    if !result.error
      $fragment = $ document.createDocumentFragment()
      i = 0
      while i < result.feed.entries.length
        $ '<article></article>'
          .append result.feed.entries[i].content
          .appendTo $fragment
        i++
      $ 'body'
        .append $fragment

google.setOnLoadCallback initialize

if document.URL.indexOf('dezeen') > -1
  feedURL = 'http://feeds.feedburner.com/dezeen'
else if document.URL.indexOf('designboom') > -1
  feedURL = 'http://www.designboom.com/feed/'
else if document.URL.indexOf('yatzer') > -1
  feedURL = 'https://www.yatzer.com/rss.xml'
else if document.URL.indexOf('archdaily') > -1
  feedURL = 'http://feeds.feedburner.com/Archdaily'
else if document.URL.indexOf('awwwards') > -1
  feedURL = 'http://feeds.feedburner.com/awwwards-sites-of-the-day'
