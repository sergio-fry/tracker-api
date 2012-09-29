# encoding: utf-8
require 'spec_helper'

module TrackerApi
  describe RgFootball do
    before(:each) do
      FakeWeb.allow_net_connect = false
      @tracker = RgFootball.new "foo", "boo"
    end

    describe "#find_torrents" do
      context "unprocessible content recieved from tracker" do
        before(:each) do
          FakeWeb.register_uri(:post, "http://rgfootball.net/tracker.php", :body => "Server is down!")
        end

        it "should raise error" do
          lambda do
            @tracker.find_torrents "Милан"
          end.should raise_error(RgFootball::ErrorWhenProcessingContent)
        end
      end

      context "correct response from tracker" do
        before(:each) do
          FakeWeb.register_uri(:post, "http://rgfootball.net/tracker.php", :body => File.read(File.join(APP_ROOT, "spec/fixtures/web/rgfootball-net-search-result.html")))
        end

        describe "search results" do
          it "should have 50 items" do
            @tracker.find_torrents("Милан").should have(50).items
          end
        end

        describe "torrent description" do
          [:category, :title, :author, :size, :seeders, :leechers, :created_at_timestamp].each do |attr|
            it "should have #{attr}" do
              @tracker.find_torrents("Милан").first.send(attr).should_not be_nil
            end
          end
        end
      end
    end
  end
end

