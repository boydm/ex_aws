defmodule ExAws.Transcoder do
  @moduledoc """
  Operations on AWS Elastic Transcoder

  https://docs.aws.amazon.com/elastictranscoder/latest/developerguide/api-reference.html
  """

  import ExAws.Utils, only: [camelize_key: 1]
  require Logger

  @namespace "/2012-09-25/"

  @type pipeline_id :: binary  
  @type job_id :: binary  
  @type preset_id :: binary


  @type transcoder_list_opts :: [
    ascending: boolean,
    page_token: binary
  ]

  @type pipeline_status :: [
    {:status, :active | :paused}
  ]

  @type pipeline_notifications :: [
    pipeline: [
      id: binary,
      notifications: [
        progressing:  binary,
        completed:    binary,
        warning:      binary,
        error:        binary
      ]
    ]
  ]

  @type test_role_opts :: [
    input_bucket: binary,
    output_bucket: binary,
    role: binary,
    topics: [] | [binary]
  ]

  ## Jobs
  ######################

  @doc """
  create_job doesn't use normal parameters.

  See [AWS Documentation](https://docs.aws.amazon.com/elastictranscoder/latest/developerguide/create-job.html)
  for the job_input map definition.
  """
  @spec create_job(job_input :: map) :: ExAws.Operation.JSON.t
  def create_job( job_input ) do
    request(:post, "jobs", job_input)
  end

  @spec get_job(job_id :: binary) :: ExAws.Operation.JSON.t
  def get_job( job_id ) do
    request(:get, "jobs/" <> job_id)
  end

  @spec cancel_job(job_id :: binary) :: ExAws.Operation.JSON.t
  def cancel_job( job_id ) do
    request(:delete, "jobs/" <> job_id)
  end
  
  @spec list_jobs_by_pipeline(pipeline_id :: binary) :: ExAws.Operation.JSON.t
  @spec list_jobs_by_pipeline(pipeline_id :: binary, opts :: transcoder_list_opts) :: ExAws.Operation.JSON.t
  def list_jobs_by_pipeline( pipeline_id, opts \\ [] ) do
    request(:get, "jobsByPipeline/" <> pipeline_id, opts)
  end
  
  @spec list_jobs_by_status(status :: binary) :: ExAws.Operation.JSON.t
  @spec list_jobs_by_status(status :: binary, opts :: transcoder_list_opts) :: ExAws.Operation.JSON.t
  def list_jobs_by_status( status, opts \\ [] ) do
    request(:get, "jobsByStatus/" <> status, opts)
  end
  

  ## Pipelines
  ######################

  @doc """
  create_pipeline doesn't use normal parameters.
  
  See [AWS Documentation](https://docs.aws.amazon.com/elastictranscoder/latest/developerguide/create-pipeline.html)
  for the pipeline_input map definition.
  """
  @spec create_pipeline(pipeline_input :: map) :: ExAws.Operation.JSON.t
  def create_pipeline( pipeline_input ) do
    request(:post, "pipelines", pipeline_input)
  end

  @spec list_pipelines(opts :: transcoder_list_opts) :: ExAws.Operation.JSON.t
  def list_pipelines( opts \\ [] ) do
    request(:get, "pipelines", opts)
  end

  @spec get_pipeline(pipeline_id :: binary) :: ExAws.Operation.JSON.t
  def get_pipeline( pipeline_id ) do
    request(:get, "pipelines/" <> pipeline_id)
  end

  @doc """
  update_pipeline doesn't use normal parameters.
  
  See [AWS Documentation](https://docs.aws.amazon.com/elastictranscoder/latest/developerguide/update-pipeline.html)
  for the pipeline_input map definition.
  """
  @spec update_pipeline(pipeline_id :: binary, pipeline_input :: map) :: ExAws.Operation.JSON.t
  def update_pipeline( pipeline_id, pipeline_input ) do
    request(:put, "pipelines/" <> pipeline_id, pipeline_input)
  end

  @spec update_pipeline_status(pipeline_id :: binary, status :: pipeline_status) :: ExAws.Operation.JSON.t
  def update_pipeline_status( pipeline_id, status ) do
    request(:post, "pipelines/" <> pipeline_id <> "/status", status)
  end

  @spec update_pipeline_notifications(pipeline_id :: binary, notifications :: pipeline_notifications) :: ExAws.Operation.JSON.t
  def update_pipeline_notifications( pipeline_id, notifications ) do
    request(:post, "pipelines/" <> pipeline_id <> "/notifications", notifications)
  end

  @spec delete_pipeline(pipeline_id :: binary) :: ExAws.Operation.JSON.t
  def delete_pipeline( pipeline_id ) do
    request(:delete, "pipelines/" <> pipeline_id)
  end


  @spec test_role(opts :: test_role_opts) :: ExAws.Operation.JSON.t
  def test_role( opts ) do
    request(:post, "roleTests", opts)
  end


  ## Pipelines
  ######################


  @doc """
  create_preset doesn't use normal parameters.
  
  See [AWS Documentation](https://docs.aws.amazon.com/elastictranscoder/latest/developerguide/create-preset.html)
  for the pipeline_input map definition.
  """
  @spec create_preset(preset_input :: map) :: ExAws.Operation.JSON.t
  def create_preset( preset_input ) do
    request(:post, "presets", preset_input)
  end

  @spec list_presets(opts :: transcoder_list_opts) :: ExAws.Operation.JSON.t
  def list_presets( opts ) do
    request(:get, "presets", opts)
  end

  @spec get_preset(preset_id :: binary) :: ExAws.Operation.JSON.t
  def get_preset( preset_id ) do
    request(:get, "presets/" <> preset_id)
  end

  @spec delete_preset(preset_id :: binary) :: ExAws.Operation.JSON.t
  def delete_preset( preset_id ) do
    request(:delete, "presets/" <> preset_id)
  end



  ########################
  ### Helper Functions ###
  ########################

  defp request(http_method, path, data \\ nil, headers \\ [], before_request \\ nil) do
    #path = [path, "?", params |> URI.encode_query] |> IO.iodata_to_binary
    ExAws.Operation.JSON.new(:elastictranscoder, %{
      http_method: http_method,
      path: @namespace <> path,
      data: normalize_data(data),
      headers: [{"content-type", "application/json"} | headers],
      before_request: before_request,
    })
  end

  # needs to be made recursive
#  defp normalize_opts(opts) do
#    opts
#    |> Enum.into(%{})
#    |> camelize_keys
#  end

  defp normalize_data(data) when is_nil(data), do: %{}
  defp normalize_data(data) when is_list(data), do: normalize_data(Enum.into(data, %{}))
  defp normalize_data(data) when is_map(data) do
    Enum.reduce(data, %{}, fn({key, value}, acc) ->
      key = camelize_key(key)
      value = cond do
        is_map(value) ->  normalize_data(value)
        is_list(value) -> normalize_data(value)
        is_atom(value) -> to_string(value)
        true -> value
      end
      Map.put(acc, key, value)
    end)
  end

end



























