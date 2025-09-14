module LocaleConcern # rubocop:disable Style/Documentation
  extend ActiveSupport::Concern

  included do
    before_action :set_locale
  end

  private

  def set_locale
    I18n.locale = extract_locale || I18n.default_locale
  end

  def extract_locale
    locale_from_params ||
      locale_from_header ||
      I18n.default_locale
  end

  def locale_from_params
    return unless params[:locale]

    params[:locale] if I18n.available_locales.map(&:to_s).include?(params[:locale])
  end

  def locale_from_header
    return unless request.env['HTTP_ACCEPT_LANGUAGE']

    header_locales = request.env['HTTP_ACCEPT_LANGUAGE'].scan(/[a-z]{2}(?:-[A-Z]{2})?/)

    header_locales.each do |locale|
      return locale if I18n.available_locales.map(&:to_s).include?(locale)

      language = locale.split('-').first
      return "#{language}-BR" if language == 'pt' && I18n.available_locales.include?(:'pt-BR')
      return language if I18n.available_locales.map(&:to_s).include?(language)
    end

    nil
  end
end
