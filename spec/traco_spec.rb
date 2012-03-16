require "spec_helper"
require "traco"

# See spec/dummy for the Rails app that has the Post model.
# http://guides.rubyonrails.org/plugins.html#add-an-acts_as-method-to-active-record

describe Traco, ".translates" do

  it "should add functionality" do
    Post.new.should_not respond_to :title
    Traco.translates Post, :title, :description
    Post.new.should respond_to :title
  end

end

describe Post, ".locales_for_column" do

  before do
    Traco.translates Post, :title
  end

  it "should list the locales, default first and then alphabetically" do
    I18n.default_locale = :fi
    Post.locales_for_column(:title).should == [
      :fi, :en, :sv
    ]
  end

end

describe Post, "#title" do

  let(:post) { Post.new(title_sv: "Hej", title_en: "Halloa", title_fi: "Moi moi") }

  before do
    Traco.translates Post, :title
    I18n.locale = :sv
    I18n.default_locale = :en
  end

  it "should give the title in the current locale" do
    post.title.should == "Hej"
  end

  it "should fall back to the default locale if locale has no column" do
    I18n.locale = :ru
    post.title.should == "Halloa"
  end

  it "should fall back to the default locale if blank" do
    post.title_sv = " "
    post.title.should == "Halloa"
  end

  it "should fall back to any other locale if default locale is blank" do
    post.title_sv = " "
    post.title_en = ""
    post.title.should == "Moi moi"
  end

  it "should return nil if all are blank" do
    post.title_sv = " "
    post.title_en = ""
    post.title_fi = nil
    post.title.should be_nil
  end

end

describe Post, "#title=" do

  before do
    Traco.translates Post, :title
    I18n.locale = :sv
  end

  let(:post) { Post.new }

  it "should assign in the current locale" do
    post.title = "Hej"
    post.title.should == "Hej"
    post.title_sv.should == "Hej"
  end

  it "should raise if locale has no column" do
    I18n.locale = :ru
    -> {
      post.title = "Privet"
    }.should raise_error(NoMethodError, /title_ru/)
  end

end

describe Post, ".human_attribute_name" do

  before do
    Traco.translates Post, :title
    I18n.locale = :sv
  end

  it "should append a known language name" do
    Post.human_attribute_name(:title_en).should == "Titel (engelska)"
  end

  it "should use abbreviation when language name is not known" do
    Post.human_attribute_name(:title_fi).should == "Titel (FI)"
  end

  it "should yield to defined translations" do
    Post.human_attribute_name(:title_sv).should == "Svensk titel"
  end

  it "should pass through the default behavior" do
    Post.human_attribute_name(:title).should == "Titel"
  end

  it "should pass through untranslated columns" do
    Post.human_attribute_name(:body_sv).should == "Body sv"
  end

end
