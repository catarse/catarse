class ScriptPolicy
  attr_reader :user

  def initialize(user:)
    @user = user
  end

  def can_read?
    done_by_dev_or_executor?
  end

  def can_create?
    done_by_dev_or_executor?
  end

  def can_update?(script)
    is_script_not_excuted?(script) && done_by_executor_or_script_creator?(script)
  end

  def can_destroy?(script)
    is_script_not_excuted?(script) && done_by_executor_or_script_creator?(script)
  end

  def can_execute?(script)
    is_script_not_excuted?(script) && done_by_executor?
  end

  def is_script_not_excuted?(script)
    script.pending? || script.with_error?
  end

  def done_by_executor_or_script_creator?(script)
    done_by_executor? || script.creator_id == user.try(:id)
  end

  def done_by_dev_or_executor?
    done_by_dev? || done_by_executor?
  end

  def done_by_executor?
    @done_by_executor ||= user.try(:admin?) && user.admin_roles.pluck(:role_label).include?('script_executor')
  end

  def done_by_dev?
    @done_by_dev ||= user.try(:admin?) && user.admin_roles.pluck(:role_label).include?('script_dev')
  end
end
