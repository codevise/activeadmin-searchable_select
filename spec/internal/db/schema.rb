ActiveRecord::Schema.define do
  create_table(:active_admin_comments, force: true) do |t|
    t.string :namespace
    t.text   :body
    t.string :resource_id,   null: false
    t.string :resource_type, null: false
    t.references :author, polymorphic: true
    t.timestamps null: false
  end
end
