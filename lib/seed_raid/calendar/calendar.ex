defmodule SeedRaid.Calendar do
  @moduledoc """
  The Calendar context.
  """

  import Ecto.Query, warn: false
  alias SeedRaid.Repo

  alias SeedRaid.Calendar.Raid

  @doc """
  Returns the list of raids.

  ## Examples

      iex> list_raids()
      [%Raid{}, ...]

  """
  def list_raids(options \\ []) do
    days_ago = Timex.now() |> Timex.shift(days: -2)
    defaults = [from: days_ago]

    options =
      defaults
      |> Keyword.merge(options)
      |> Enum.into(%{})

    query =
      from(r in Raid, where: r.when > ^options.from and r.pinned == true, order_by: [asc: r.when])

    Repo.all(query)
  end

  @doc """
   unpin all post from a given channel
  """
  def unpin_all(region, side) do
    query = from(r in Raid, where: r.region == ^region and r.side == ^side and r.pinned == true)

    case Repo.update_all(query, set: [pinned: false]) do
      {changed, _} when is_integer(changed) ->
        changed

      _ ->
        0
    end
  end

  @doc """
  Gets a single raid.

  Raises `Ecto.NoResultsError` if the Raid does not exist.

  ## Examples

      iex> get_raid!(123)
      %Raid{}

      iex> get_raid!(456)
      ** (Ecto.NoResultsError)

  """
  def get_raid!(id), do: Repo.get!(Raid, id)

  @doc """
  Creates a raid.

  ## Examples

      iex> create_raid(%{field: value})
      {:ok, %Raid{}}

      iex> create_raid(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_raid(attrs \\ %{}) do
    %Raid{}
    |> Raid.changeset(attrs)
    |> Repo.insert()
  end

  def create_or_update_raid(attrs \\ %{}) do
    %Raid{}
    |> Raid.changeset(attrs)
    |> Repo.insert(
      on_conflict: [
        set: [when: attrs.when, seeds: attrs.seeds, type: attrs.type, content: attrs.content]
      ],
      conflict_target: :discord_id
    )
  end

  @doc """
  Updates a raid.

  ## Examples

      iex> update_raid(raid, %{field: new_value})
      {:ok, %Raid{}}

      iex> update_raid(raid, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_raid(%Raid{} = raid, attrs) do
    raid
    |> Raid.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a Raid.

  ## Examples

      iex> delete_raid(raid)
      {:ok, %Raid{}}

      iex> delete_raid(raid)
      {:error, %Ecto.Changeset{}}

  """
  def delete_raid(%Raid{} = raid) do
    Repo.delete(raid)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking raid changes.

  ## Examples

      iex> change_raid(raid)
      %Ecto.Changeset{source: %Raid{}}

  """
  def change_raid(%Raid{} = raid) do
    Raid.changeset(raid, %{})
  end
end
