class AssignExistingPostsToUnknownUser < ActiveRecord::Migration[8.1]
  def up
    say_with_time "Creating 'Unknown' user and assigning posts without user" do
      unknown = User.find_or_create_by!(email: 'unknown@example.com') do |u|
        # set a random password since we won't sign in as this user
        u.password = SecureRandom.hex(20)
        # optional: set a visible username
        u.username = 'Unknown'
      end

      # assign all posts without a user to the unknown user
      BlogPost.where(user_id: nil).update_all(user_id: unknown.id)
    end
  end

  def down
    say_with_time "Reverting posts assigned to 'Unknown' user" do
      unknown = User.find_by(email: 'unknown@example.com')
      if unknown
        BlogPost.where(user_id: unknown.id).update_all(user_id: nil)
        unknown.destroy
      end
    end
  end
end
