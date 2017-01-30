[![Build Status](https://travis-ci.org/appunite/link_preview.svg?branch=master)](https://travis-ci.org/appunite/link_preview)

# LinkPreview

LinkPreview is a package that tries to receive meta information from given http(s) address

## Installation

1. Add link_preview to your list of dependencies in `mix.exs`:

  ```elixir
    def deps do
      [
        {:link_preview, "~> 1.0.0"}
      ]
    end
  ```

2. For Elixir < 1.4 ensure link_preview is started before your application:

  ```elixir
    def application do
      [applications: [:link_preview]]
    end
  ```

## Example usage

You just need to execute:

  ```elixir
    LinkPreview.create("www.yahoo.pl")
  ```

in response you'll receive

  ```elixir
    %LinkPreview.Page{
      description: "News, email and search are just the beginning. Discover more every day. Find your yodel.",
      images: [%{url: "https://s.yimg.com/dh/ap/default/130909/y_200_a.png"}],
      original_url: "www.yahoo.pl",
      title: "Yahoo",
      website_url: "yahoo.com"
  }
  ```

## License

Copyright 2017 Tobiasz Małecki <tobiasz.malecki@appunite.com>

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.
