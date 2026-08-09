# frozen_string_literal: true

require 'json'
require 'net/http'
require 'uri'

module FutbolLibreHoy
  DEFAULT_BASE_URL = 'https://verfutbollibre.net'
  CALENDAR_PATH = '/api/v1/calendar'

  module_function

  def parse_calendar(input)
    data = input.is_a?(String) ? JSON.parse(input) : input
    matches = Array(data['matches']).map { |m| normalize_match(m) }
    {
      'source' => data['source'] || 'Futbol Libre',
      'homepage' => data['homepage'] || DEFAULT_BASE_URL,
      'date' => data['date'] || '',
      'filter' => data['filter'] || 'all',
      'count' => data.key?('count') ? data['count'].to_i : matches.length,
      'matches' => matches
    }
  end

  def normalize_match(raw)
    score = nil
    if raw['score'].is_a?(Array) && raw['score'].length >= 2
      score = [raw['score'][0].to_i, raw['score'][1].to_i]
    end
    team = lambda do |t, fallback|
      t = t.is_a?(Hash) ? t : {}
      { 'id' => t['id'].to_i, 'name' => (t['name'] || fallback).to_s, 'slug' => (t['slug'] || '').to_s }
    end
    {
      'id' => raw['id'].to_i,
      'status' => (raw['status'] || '').to_s,
      'kickoff_at' => (raw['kickoff_at'] || '').to_s,
      'home' => team.call(raw['home'], 'Home'),
      'away' => team.call(raw['away'], 'Away'),
      'score' => score,
      'minute' => raw['minute'].nil? ? nil : raw['minute'].to_i,
      'tournament' => team.call(raw['tournament'], 'Tournament'),
      'url' => (raw['url'] || DEFAULT_BASE_URL).to_s
    }
  end

  def format_score(m)
    m['score'] ? "#{m['score'][0]}-#{m['score'][1]}" : 'vs'
  end

  def format_line(m)
    score = format_score(m)
    pair = "#{m['home']['name']} #{score} #{m['away']['name']}"
    return "#{m['minute']}' #{pair}" if m['status'] == 'live' && !m['minute'].nil?
    return "LIVE #{pair}" if m['status'] == 'live'
    return "#{m['home']['name']} vs #{m['away']['name']}" if m['status'] == 'before'
    pair
  end

  def fetch_calendar(date: nil, filter: 'all', base_url: DEFAULT_BASE_URL)
    uri = URI("#{base_url.sub(%r{/$}, '')}#{CALENDAR_PATH}")
    q = {}
    q['date'] = date if date
    q['filter'] = filter if filter && filter != 'all'
    uri.query = URI.encode_www_form(q) unless q.empty?
    res = Net::HTTP.get_response(uri)
    raise "HTTP #{res.code}" unless res.is_a?(Net::HTTPSuccess)
    parse_calendar(res.body)
  end
end
