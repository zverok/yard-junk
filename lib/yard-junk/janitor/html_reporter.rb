# frozen_string_literal: true
require 'erb'

module YardJunk
  class Janitor
    # Reporter that just outputs everything in HTML format. Useful
    # for usage with Jenkins. See {BaseReporter} for details about reporters.
    #
    class HtmlReporter < BaseReporter
      HEADER = <<~HTML
        <!DOCTYPE html>
        <html lang="en">
          <header>
            <meta charset='UTF-8' />
            <title>YARD-Junk Report</title>
            <style>
              body, html {
              }
              body {
                font-family: "Helvetica Neue",Helvetica,Arial,sans-serif;
                margin: 0;
                padding: 20px;
              }
              h2 {
                font-size: 1.6rem;
              }
              h2 small {
                color: gray;
                font-weight: normal;
              }
              span.path {
                font-family: Consolas, "Liberation Mono", Menlo, Courier, monospace;
                font-size: 85%;
              }
              .problem { color: red; }
              .notice { color: gray; }
              p.stats {
                padding: 10px;
                font-size: 1.2em;
                border: 1px dotted silver;
              }
            </style>
          </header>
          <body>
            <h1>YARD Validation Report</h1>
      HTML

      FOOTER = <<~HTML
          </body>
        </html>
      HTML

      SECTION = <<-HTML
      <h2 class="<%= title == 'Notices' ? 'notice' : 'problem' %>">
        <%= title %>
        <small>(<%= explanation %>)</small>
      </h2>
      HTML

      ROW = <<-HTML
      <li><span class="path"><%= file %>:<%= line %></span>: <%= message %></li>
      HTML

      STATS = <<-HTML
      <p class="stats">
        <span class="<%= 'problem' unless errors.zero? %>"><%= errors %> failures</span>,
        <span class="<%= 'problem' unless problems.zero? %>"><%= problems %> problems</span>
        (ready in <%= duration %>)
      </p>
      HTML

      Helper = Class.new(OpenStruct) do
        def the_binding
          binding
        end
      end

      attr_reader :html

      def initialize(*)
        super
        @html = HEADER.dup
      end

      def finalize
        @html << FOOTER
        @io.puts(@html)
      end

      private

      def _stats(**stat)
        render(STATS, **stat)
      end

      def header(title, explanation)
        render(SECTION, title: title, explanation: explanation)
      end

      def row(message)
        render(ROW, **message.to_h)
      end

      def render(template, values)
        html <<
          ERB.new(template)
             .result(Helper.new(values).the_binding)
      end
    end
  end
end
