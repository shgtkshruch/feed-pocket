$ = require 'jquery'
_ = require 'underscore'
async = require 'async'
cheerio = require 'cheerio'
moment = require 'moment'
fullpage = require 'fullpage.js'

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
      async.whilst (->
        i < entries.length
      ), ((cb) ->
        article = {}
        $$ = cheerio.load entries[i].content,
          normalizeWhitespace: true
        site.parse article, $$
        article.title = entries[i].title
        article.link = entries[i].link
        article.date = moment(new Date(entries[i].publishedDate)).format('D MMMM YYYY, HH:hh')
        article.anchor = i + 1
        $ '<img/>'
          .attr 'src', article.src
          .on 'load', ->
            $fragment.append articleTemplate article
            i++
            cb()
          .on 'error', ->
            article.src = 'http://placehold.it/350x350?text=+'
            $fragment.append articleTemplate article
            i++
            cb()
      ), (err) ->
        $ '#fullpage'
          .append $fragment
          .fullpage
            menu: '#fullpageMenu'
            afterRender: ->
              $article = $('.article').eq(0)
              $ '#cover'
                .css
                  top: $article.find('.article__header').offset().top
                  height: $article.find('.article__header').height()
              .fadeIn()
            onLeave: (index, nextIndex, direction) ->
              if Math.abs(index - nextIndex) > 1 or direction is 'up'
                index = nextIndex - 1
              $articleHeader = $('.article').eq(index).find('.article__header')
              $ '#cover'
                .css
                  top: $articleHeader.position().top
                  height: $articleHeader.height()

google.setOnLoadCallback initialize
