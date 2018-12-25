class InstallFuzzystrmatch < ActiveRecord::Migration[5.2]
  def change
    enable_extension 'plpgsql'
    enable_extension "pg_trgm"
    enable_extension 'fuzzystrmatch'
  end
end
