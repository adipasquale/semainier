require "prawn"
require "date"
require "active_support/all"

def week_number(date)
  date.strftime("%-V").to_i
end

def wdaym(date)
  date.sunday? ? 6 : date.wday - 1
end

DAYS = %w[lundi mardi mercredi jeudi vendredi samedi dimanche]
MONTHS = %w[janvier février mars avril mai juin juillet août septembre octobre novembre decembre]

Prawn::Fonts::AFM.hide_m17n_warning = true
pdf = Prawn::Document.generate("semainier.pdf", page_size: "A4", margin: 0) do
  stroke_color "cccccc"

  today = Date.today
  first = today.beginning_of_month.beginning_of_week
  last = (today + 2.months).end_of_month.end_of_week
  first_week_number = week_number(first)
  weeks_count = (last - first).to_i.days.in_weeks.ceil

  define_grid(columns: 7, rows: weeks_count + 1, gutter: 0)
  # grid.show_all
  DAYS.each_with_index do |name, index|
    grid(0, index).bounding_box do |box|
      stroke_bounds
      text name, align: :center, valign: :center
    end
  end

  (first..last).each do |date|
    week_index = week_number(date) - first_week_number
    week_index += 52 if date.year > first.year && week_number(date) < 10
    grid(week_index + 1, wdaym(date)).bounding_box do |box|
      stroke_bounds
      text = date.day == 1 ? "#{MONTHS[date.month - 1]} #{date.day}" : date.day.to_s
      text text, align: :right
    end
  end
end

`open semainier.pdf`
