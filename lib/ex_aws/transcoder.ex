defmodule ExAws.Transcoder do
  @moduledoc """
  Operations on AWS Elastic Transcoder

  https://docs.aws.amazon.com/elastictranscoder/latest/developerguide/api-reference.html
  """

  import ExAws.Utils, only: [camelize_keys: 1, upcase: 1]
  require Logger

  @namespace "2012-09-25"

  @type job_input :: map  

  @type pipeline_id :: binary  
  @type job_id :: binary  
  @type preset_id :: binary




  ## Jobs
  ######################

  @spec create_job(job_input :: job_input) :: ExAws.Operation.JSON.t
  def create_job( job_input_data ) do
    request(:post, :jobs, job_input_data)
  end


  ########################
  ### Helper Functions ###
  ########################

  defp request(http_method, path, data) do
    %ExAws.Operation.RestQuery{
      http_method: http_method,
      path: path,
      params: data,
      service: :elastictranscoder
    }
  end

  defp normalize_opts(opts) do
    opts
    |> Enum.into(%{})
    |> camelize_keys
  end

end
