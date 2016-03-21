import $ from 'jquery';
import _ from 'underscore';
import cheerio from 'cheerio';
import moment from 'moment';
import fullpage from 'fullpage.js';

var articleTemplate = _.template($('#article-template').text());

var site = (() => {
  if (document.URL.indexOf('dezeen') > -1) {
    return {
      url: 'http://feeds.feedburner.com/dezeen',
      parse: (article, $$) => {
        article.src = $$('p:first-child > a > img').attr('src'),
        article.text = $$('p').next().html()
      }
    }
  } else if (document.URL.indexOf('designboom') > -1) {
    return {
      url: 'http://www.designboom.com/feed/',
      parse: (article, $$) => {
        article.src = $$('img').attr('src'),
        article.text = $$('p').html()
      }
    }
  } else if (document.URL.indexOf('yatzer') > -1) {
    return {
      url: 'https://www.yatzer.com/rss.xml',
      parse: (article, $$) => {
        article.src = $$('img').attr('src'),
        article.text = $$('p').html()
      }
    }
  } else if (document.URL.indexOf('archdaily') > -1) {
    return {
      url: 'http://feeds.feedburner.com/Archdaily',
      parse: (article, $$) => {
        article.src = $$('img').attr('src'),
        article.text = $$('p').text()
      }
    }
  } else if (document.URL.indexOf('awwwards') > -1) {
    return {
      url: 'http://feeds.feedburner.com/awwwards-sites-of-the-day',
      parse: (article, $$) => {
        article.src = $$('img').attr('src'),
        article.text = $$.html().replace(/<div>.+<\/div>/, '');
      }
    }
  }
})();

// google feed apiを読み込む
google.load('feeds', 1);

// feedが読み込まれたら実行される処理
var initialize = () => {
  // google feed apiを利用してfeedを読み込む
  var feed = new google.feeds.Feed(site.url);
  feed.setNumEntries(10);
  feed.load(result => {
    if (!result.error) {
      var entries = result.feed.entries;
      var $fragment = $(document.createDocumentFragment());
      var $cover = $('#cover');
      var $scroll = $('#scroll');
      var i = 0;

      // RSSをスクレイピングして各記事のオブジェクトを用意
      while (i < entries.length) {
        var article = {};
        var $$ = cheerio.load(entries[i].content, {
          normalizeWhitespace: true
        });

        // RSSをスクレイピングしてarticleのsrcとtextを設定
        site.parse(article, $$);

        // その他のプロパティをarticleに設定
        article.title = entries[i].title;
        article.link = entries[i].link;
        article.date = moment(new Date(entries[i].publishedDate)).format('D MMMM YYYY, HH:hh');
        article.anchor = i + 1;

        // fragmentにarticleを追加
        $fragment.append(articleTemplate(article));

        i++;
      }

      $('#fullpage')
        // 記事をページに追加
        .append($fragment)
        // fullpage.jsの設定
        .fullpage({
          menu: '#fullpageMenu',
          // fullpageがレンダーされたら実行される処理
          afterRender: () => {
            var $article = $('.article').eq(0);
            var $articleHeader = $article.find('.article__header');

            // 一番最初の記事の画像がロードされたらカバーを描画
            $article.find('img').on('load', () => {
              $cover.css({
                top: $articleHeader.offset().top,
                height: $articleHeader.height()
              }).fadeIn();

            // スクロールを促すアイコンを表示
            $scroll.fadeIn();
            });
          },
          // セクションを移動したら実行される処理
          onLeave: (index, nextIndex, direction) => {
            // 下にスクロールしたらスクロールを促すアイコンを非表示
            if (direction === 'down') {
              $scroll.fadeOut();
            }

            // ２個以上ジャンプするか上に移動したらindexを調整
            if (Math.abs(index - nextIndex) > 1 || direction === 'up') {
              index = nextIndex - 1;
            }

            var $articleHeader = $('.article').eq(index).find('.article__header');

            // カバーの位置と高さを調整
            $cover.css({
              top: $articleHeader.position().top,
              height: $articleHeader.height()
            });
          }
        });
    }
  });
};

// ページのコンテンツが読み込まれたらinitialize関数を実行
google.setOnLoadCallback(initialize);
