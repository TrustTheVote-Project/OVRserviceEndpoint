class AddParamsToPosts < ActiveRecord::Migration[5.1]
  def change
    add_column :posts, :query_string, :text
  end
end
