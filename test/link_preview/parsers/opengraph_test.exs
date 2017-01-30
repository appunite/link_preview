# defmodule LinkPreview.Parsers.OpengraphTest do
#   use LinkPreview.Case
#   alias LinkPreview.Parsers.Opengraph
#   alias LinkPreview.Page
#
#   @page %Page{original_url: "http://example.com/", website_url: "example.com"}
#
#   describe "title" do
#     test "optimistic case" do
#       assert Opengraph.title(@page, @opengraph) == %Page{@page | title: "Opengraph Test Title"}
#     end
#
#     test "pessimistic case" do
#       assert Opengraph.title(@page, @html) == @page
#     end
#   end
#
#   describe "description" do
#     test "optimistic case" do
#       assert Opengraph.description(@page, @opengraph) == %Page{@page | description: "Opengraph Test Description"}
#     end
#
#     test "pessimistic case" do
#       assert Opengraph.description(@page, @html) == @page
#     end
#   end
#
#   describe "images" do
#     test "optimistic case" do
#       assert Opengraph.images(@page, @opengraph).images == [
#         %{url: "http://example.com/images/og1.jpg"},
#         %{url: "http://example.com/images/og2.jpg"}
#       ]
#     end
#
#     test "pessimistic case" do
#       assert Opengraph.images(@page, @html) == @page
#     end
#   end
# end
