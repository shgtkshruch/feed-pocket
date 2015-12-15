$ = require 'jquery'
_ = require 'underscore'
cheerio = require 'cheerio'
moment = require 'moment'

articleTemplate = _.template $('#article-template').text()

site = (->
  if document.URL.indexOf('dezeen') > -1
    url:  'http://feeds.feedburner.com/dezeen'
    parse: (article, $$) ->
      article.src = $$('p:first-child > a > img').attr 'src'
      article.text = $$('p').next().html()
  else if document.URL.indexOf('designboom') > -1
    url:  'http://www.designboom.com/feed/'
    parse: (article, $$) ->
      article.src = $$('img').attr('src')
      article.text = $$('p').html()
  else if document.URL.indexOf('yatzer') > -1
    url:  'https://www.yatzer.com/rss.xml'
    parse: (article, $$) ->
      article.src = $$('img').attr('src')
      article.text = $$('p').html()
  else if document.URL.indexOf('archdaily') > -1
    url:  'http://feeds.feedburner.com/Archdaily'
    parse: (article, $$) ->
      article.src = $$('img').attr('src')
      article.text = $$('p').text()
  else if document.URL.indexOf('awwwards') > -1
    url:  'http://feeds.feedburner.com/awwwards-sites-of-the-day'
    parse: (article, $$) ->
      article.src = $$('img').attr('src')
      article.text = $$.html().replace(/<div>.+<\/div>/, '')
)()

google.load 'feeds', 1

initialize = ->
  feed = new google.feeds.Feed site.url
  feed.setNumEntries 10
  feed.load (result) ->
    if !result.error
      entries = result.feed.entries
      $fragment = $ document.createDocumentFragment()
      i = 0
      while i < entries.length
        console.log entries[i]
        article = {}
        $$ = cheerio.load entries[i].content,
          normalizeWhitespace: true
        site.parse article, $$
        article.title = entries[i].title
        article.link = entries[i].link
        article.date = moment(new Date(entries[i].publishedDate)).format('D MMMM YYYY, HH:hh')
        $ '<article></article>'
          .append articleTemplate article
          .appendTo $fragment
        i++
      $ 'body'
        .append $fragment

google.setOnLoadCallback initialize

