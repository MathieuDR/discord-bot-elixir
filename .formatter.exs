# Used by "mix format"
[
  inputs: [
    "{mix,.formatter,.credo}.exs",
    "{config,lib,test}/**/*.{ex,exs}"
  ],
  import_deps: [
    :typed_struct
  ],
  locals_without_parens: [
    assert_with_msg: 2
  ],
  plugins: [Phoenix.LiveView.HTMLFormatter, Styler]
]
