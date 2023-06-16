#!/usr/bin/env ruby
# frozen_string_literal: true

require 'json'

PROJECTS_DIR = "#{ENV['HOME']}/Projets/"
PROJECT_MANAGER_CONFIG = "#{ENV['USERPROFILE']}/AppData/Roaming/Code - Insiders/User/globalStorage/alefragnani.project-manager/projects.json"

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
