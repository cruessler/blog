require 'uri'

module Jekyll
  class ElmLogoSnippetBlock < Liquid::Block

    def render(context)
      snippet = super.strip
      encoded_snippet = URI.encode_www_form_component(snippet)
      link = "#{ENV['ELM_LOGO_URL']}?initialCommandLine=#{encoded_snippet}"

      "```
#{snippet}
```

<a href=\"#{link}\">Open snippet in elm-logo (in elm-logo, click “Run” to run it)</a>"
    end
  end
end

Liquid::Template.register_tag('elm_logo_snippet', Jekyll::ElmLogoSnippetBlock)
