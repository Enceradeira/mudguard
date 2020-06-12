# frozen_string_literal: true

module TestProjects
  class << self
    def path_to(sub_path)
      file = __FILE__
      File.expand_path(sub_path, File.dirname(file))
    end
  end
  private_class_method :path_to

  PATH_TO_MUDDY_PROJECT = path_to("muddy_project")
  PATH_TO_CLEAN_PROJECT = path_to("clean_project")
  PATH_TO_EMPTY_DIR = path_to("empty_dir")
  PATH_TO_HIERARCHICAL_PROJECT = path_to("hierarchical_project")
  PATH_TO_PRJ_WITH_INVALID_RUBY = path_to("project_with_invalid_ruby")
  PATH_TO_PRJ_WITHOUT_MUDG_FILE = path_to("project_without_mudguard_file")
end
