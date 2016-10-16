require 'capybara'
require 'youtube-dl'

session = Capybara::Session.new(:selenium)
session.visit 'https://caster.io/login'

session.fill_in 'Username', with: 'tabby@cat.com'
session.fill_in 'Password', with: '14m4+466yc4+'
session.find('#rcp_login_submit').click

session.visit 'https://caster.io/episode-list'
links = session.find_all('.entry-content li a').map { |l| l[:href] }

links.each do |link|
  session.visit link
  begin
    script = session.find('script[type="application/ld+json"]', visible: false)
    content = JSON.parse(script.text(:all))
    video_link = content['@id']
    YoutubeDL.download(video_link)
  rescue
    begin
      script = session.first('p script', visible: false)
      content = script['src']
      video_link = content.sub('medias', 'iframe').sub('.jsonp', '').sub('com', 'net')
      if video_link != 'https://fast.wistia.net/assets/external/E-v1.js'
        YoutubeDL.download(video_link)
      else
        title = session.first('h1.entry-title').text.sub('Lesson ', '0').sub(':', ' -') + '.mp4'
        video_link = session.first('source', visible: false)['src']
        YoutubeDL.download(video_link, output: title)
      end
    rescue
      puts "You gotta debug this #{link} yourself, sadly"
    end
  end
end

