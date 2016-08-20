defmodule ExAws.Transcoder do
  @moduledoc """
  Operations on AWS Elastic Transcoder

  https://docs.aws.amazon.com/elastictranscoder/latest/developerguide/api-reference.html
  """

  import ExAws.Utils, only: [camelize_keys: 1, upcase: 1]
  require Logger

  @namespace "/2012-09-25/"

  @type job_input :: map  

  @type pipeline_id :: binary  
  @type job_id :: binary  
  @type preset_id :: binary




  ## Jobs
  ######################

  @spec create_job(job_input :: job_input) :: ExAws.Operation.JSON.t
  @spec create_job(job_input :: binary) :: ExAws.Operation.JSON.t
  def create_job( job_input_data ) when is_map(job_input_data) do
    data = job_input_data
      |> normalize_opts
    request(:post, "jobs", data)
  end


  ########################
  ### Helper Functions ###
  ########################

  defp request(http_method, path, data, headers \\ [], before_request \\ nil) do
    #path = [path, "?", params |> URI.encode_query] |> IO.iodata_to_binary
    ExAws.Operation.JSON.new(:elastictranscoder, %{
      http_method: http_method,
      path: @namespace <> path,
      data: data,
      headers: [{"content-type", "application/json"} | headers],
      before_request: before_request,
    })
  end

  defp normalize_opts(opts) do
    opts
    |> Enum.into(%{})
    |> camelize_keys
  end

end
