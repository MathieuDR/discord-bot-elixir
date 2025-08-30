defmodule Extensions.Credo.FixComments do
  @moduledoc """
  Looks for FIX* comments with an optional @YEAR-MONTH-DAY annotation.

  Fails when any of the date annotations is today or in the past.
  """

  use Credo.Check,
    category: :documentation,
    base_priority: :high,
    explanations: [
      check: """
      Looks for FIX* comments with an optional @YEAR-MONTH-DAY annotation.

      Fails when any of the date annotations is today or in the past.
      """,
      params: [
        regex: "All lines matching this Regex will yield an issue."
      ]
    ]

  @comment_regex ~r/# *(FIX[A-Z]*):? *(.*)$/i
  @date_regex ~r/@(\d{4})[-.](\d{2})[-.](\d{2})/

  # you can configure the basics of your check via the `use Credo.Check` call
  @doc false
  @impl true
  def run(%SourceFile{} = source_file, params) do
    # IssueMeta helps us pass down both the source_file and params of a check
    # run to the lower levels where issues are created, formatted and returned
    issue_meta = IssueMeta.for(source_file, params)

    source_file
    |> SourceFile.lines()
    |> Enum.reduce([], fn {line_no, line}, issues ->
      case check_line(line) do
        :ok ->
          issues

        {warn_or_fail, error_opts} ->
          error_opts = Keyword.put(error_opts, :line_no, line_no)

          [new_issue(warn_or_fail, issue_meta, error_opts) | issues]
      end
    end)
  end

  defp check_line(line) do
    case Regex.run(@comment_regex, line) do
      nil ->
        :ok

      [full_comment, fix_annotation, context] ->
        context = String.trim(context)

        {fail_or_warn(context), message: "#{fix_annotation}: #{context}", trigger: full_comment}
    end
  end

  defp fail_or_warn(context) do
    case Regex.run(@date_regex, context) do
      nil ->
        :warn

      [_at_date, year, month, day] ->
        date =
          Date.new!(
            String.to_integer(year),
            String.to_integer(month),
            String.to_integer(day)
          )

        if today_or_in_the_past?(date) do
          :fail
        else
          :warn
        end
    end
  end

  defp today_or_in_the_past?(date) do
    today = Date.from_erl!(:erlang.date())

    Date.compare(date, today) in [:eq, :lt]
  end

  defp new_issue(:warn, issue_meta, issue_opts) do
    issue_meta
    |> with_exit_status(0)
    |> format_issue(issue_opts)
  end

  defp new_issue(:fail, issue_meta, issue_opts) do
    issue_meta
    |> with_exit_status(1)
    |> format_issue(issue_opts)
  end

  defp with_exit_status({IssueMeta, source_file, params}, exit_status) do
    {IssueMeta, source_file, Keyword.put_new(params, :exit_status, exit_status)}
  end
end
