defmodule Issues.GithubIssues do
  require Logger

  @user_agent [{"User-agent", "Elixir dave@pragprog.com"}]
  @github_url Application.get_env(:issues, :github_url)


  def fetch(user, project) do
    Logger.info("Fetching #{user}'s project #{project}")
    issues_url(user,project)
    |> HTTPoison.get(@user_agent)
    |> handle_response
  end

  @spec issues_url(any, any) :: <<_::64, _::_*8>>
  def issues_url(user, project) do
    "#{@github_url}/repos/#{user}/#{project}/issues"
  end

  @spec handle_response(
          {:ok,
           %{
             :body =>
               binary
               | maybe_improper_list(
                   binary | maybe_improper_list(any, binary | []) | byte,
                   binary | []
                 ),
             :status_code => any,
             optional(any) => any
           }}
        ) ::
          {:error,
           false
           | nil
           | true
           | binary
           | [false | nil | true | binary | list | number | {any, any, any} | map]
           | number
           | %{
               optional(atom | binary | {any, any, any}) =>
                 false | nil | true | binary | list | number | {any, any, any} | map
             }}
          | {:ok,
             false
             | nil
             | true
             | binary
             | [false | nil | true | binary | list | number | {any, any, any} | map]
             | number
             | %{
                 optional(atom | binary | {any, any, any}) =>
                   false | nil | true | binary | list | number | {any, any, any} | map
               }}
  def handle_response({:ok, %{status_code: status_code, body: body}}) do
    Logger.info "Got response status code=#{status_code}"
    {status_code
    |> check_for_error,
    body
    |> Poison.Parser.parse!}
  end

  @spec check_for_error(any) :: :error | :ok
  def check_for_error(200) do
    :ok
  end

  def check_for_error(_) do
    :error
  end
end
