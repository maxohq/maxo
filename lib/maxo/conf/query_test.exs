defmodule Maxo.Conf.QueryTest do
  use ExUnit.Case, async: true
  use Mneme, action: :accept, default_pattern: :last
  alias Maxo.Conf.Query
  alias Maxo.Conf.Util
  alias Maxo.Conf.{Context, Column, Table, State, Relation}

  setup :setup_conf

  describe "get_table" do
    test "works", %{conf: conf} do
      res = Query.get_table(conf, "users")

      auto_assert(
        %{
          columns: [
            %{comment: "", name: "email", nullable: false, primary: false, type: "string"},
            %{comment: "", name: "id", nullable: false, primary: true, type: "int"},
            %{comment: "", name: "name", nullable: false, primary: false, type: "string"},
            %{comment: "", name: "password_hash", nullable: false, primary: false, type: "string"}
          ],
          comment: "",
          name: "users",
          relations: [
            %{
              cardinality: "o2m",
              comment: "",
              dest_column: "id",
              dest_table: "users",
              src_column: "users_id",
              src_table: "memberships"
            }
          ]
        } <- res
      )
    end
  end

  def setup_conf(_) do
    {:ok, conf} = Maxo.Conf.start_link()

    Maxo.Conf.add_context!(conf, "users")
    Maxo.Conf.add_context!(conf, "tags")
    Maxo.Conf.add_context!(conf, "voting")
    Maxo.Conf.add_context!(conf, "profiles")

    Maxo.Conf.add_context!(conf, "admin/users")
    Maxo.Conf.add_context!(conf, "admin/profiles")

    Maxo.Conf.add_table!(conf, "users")
    Maxo.Conf.add_column!(conf, "users", %{name: "name", type: "string", nullable: false})
    Maxo.Conf.add_column!(conf, "users", %{name: "email", type: "string", nullable: false})

    Maxo.Conf.add_column!(conf, "users", %{name: "password_hash", type: "string", nullable: false})

    Maxo.Conf.add_table!(conf, "teams")
    Maxo.Conf.add_column!(conf, "teams", %{name: "name", type: "string", nullable: false})

    Maxo.Conf.add_table!(conf, "memberships")
    Maxo.Conf.add_column!(conf, "memberships", %{name: "users_id", type: "int", nullable: false})
    Maxo.Conf.add_column!(conf, "memberships", %{name: "teams_id", type: "int", nullable: false})

    ## relations can be executed after all tables, that simplifies DB schema maintenance
    Maxo.Conf.add_relation!(conf, "memberships/users_id", "users/id", "o2m")
    Maxo.Conf.add_relation!(conf, "memberships/teams_id", "teams/id", "o2m")
    {:ok, %{conf: conf}}
  end
end
