class PwaController < ApplicationController
  skip_before_action :require_admin!, raise: false
  layout false

  def manifest
    response.headers["Content-Type"] = "application/manifest+json"
    render "pwa/manifest.json"
  end

  def service_worker
    response.headers["Content-Type"] = "application/javascript"
    render "pwa/service-worker.js"
  end
end
