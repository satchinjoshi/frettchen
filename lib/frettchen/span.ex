defmodule Frettchen.Span do
  alias Jaeger.Thrift.{Log, Span, Tag, TagType}
  alias Frettchen.Trace

  @moduledoc """
  """

  @doc """
  close/1 closes a span by calculating the duration as the 
  difference between the start time and the current time
  """
  def close(span = %Span{}) do
    %{span | duration: (Frettchen.Helpers.current_time() - span.start_time)}
  end

  @doc """
  open/1 creates a new span with a given name 
  """
  def open(name) do
    %{Span.new() | 
      operation_name: Frettchen.Helpers.format_name(name),
      trace_id_low: Frettchen.Helpers.random_id(),
      trace_id_high: 0,
      span_id: Frettchen.Helpers.random_id(),
      parent_span_id: 0,
      flags: 1,
      start_time: Frettchen.Helpers.current_time(),
      logs: [],
      tags: []
    } 
  end

  @doc """
  open/2 creates a new span with a given name and
  assigns the passed span as the parent_id
  """
  def open(name, span = %Span{}) do
    %{open(name) | trace_id_low: span.trace_id_low, parent_span_id: span.span_id}
  end
  
  @doc """
  open/2 creates a new span with a given name and
  assigns the passed trace as the trace_id
  """
  def open(name, trace = %Trace{}) do
    %{open(name) | trace_id_low: trace.id}
  end

  @doc """
  tag/3 adds a tag struct to the tags list of
  a span.
  """
  def tag(span = %Span{}, key, value) when is_binary(key) do
    tag = 
      %{Tag.new | key: key} 
      |> tag_merge_value(value)

    %{span | tags: [tag | span.tags]}
  end

  defp tag_merge_value(tag = %Tag{}, value) when is_binary(value) do
    %{tag | v_type: 0, v_str: value}
  end
  defp tag_merge_value(tag = %Tag{}, value) when is_float(value) do
    %{tag | v_type: 1, v_double: value}
  end
  defp tag_merge_value(tag = %Tag{}, value) when is_boolean(value) do
    %{tag | v_type: 2, v_bool: value}
  end
  defp tag_merge_value(tag = %Tag{}, value) when is_integer(value) do
    %{tag | v_type: 3, v_long: value}
  end
end