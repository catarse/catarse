Autotest.add_discovery { "rails" }
Autotest.add_discovery { "rspec2" }

Autotest.add_hook :initialize do |at|
  at.add_mapping(%r%^spec/acceptance/.*_spec.rb$%, true) { |filename, _|
    filename
  }

  at.add_mapping(%r%^app/(models|controllers|helpers|lib)/.*rb$%, true) {
    at.files_matching %r%^spec/acceptance/.*_spec.rb$%
  }

  at.add_mapping(%r%^app/views/(.*)$%, true) {
    at.files_matching %r%^spec/acceptance/.*_spec.rb$%
  }
end
