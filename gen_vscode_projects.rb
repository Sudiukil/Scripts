#!/usr/bin/env ruby
# frozen_string_literal: true

# Script to update Project Manager (VSCode extension) config from a projects folder (slap it into a User task in VSCode)

require 'json'

PROJECTS_DIR = "#{ENV['HOME']}/Projets/"
# rubocop:disable Layout/LineLength
PROJECT_MANAGER_CONFIG = "#{ENV['USERPROFILE']}/AppData/Roaming/Code - Insiders/User/globalStorage/alefragnani.project-manager/projects.json"
# rubocop:enable Layout/LineLength

files = []

Dir.foreach(PROJECTS_DIR) do |filename|
  next if ['.', '..'].include?(filename)

  files << {
    "name": filename,
    "rootPath": "vscode-remote://wsl+Ubuntu-22.04#{PROJECTS_DIR}#{filename}",
    "paths": [],
    "tags": [],
    "enabled": true
  }
end

File.write(PROJECT_MANAGER_CONFIG, JSON.generate(files))
