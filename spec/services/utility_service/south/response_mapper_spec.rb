require 'rails_helper'

describe UtilityService::South::ResponseMapper do
  describe '#retrieve_notes' do
    subject(:mapped_notes) do
      described_class.new.retrieve_notes(response_code, 'Notas' => [note])[:notes]
    end

    let(:response_code) { Faker::Number.number(digits: 3) }
    let(:mapped_note) { mapped_notes.first }
    let(:review) { [true, false].sample }
    let(:first_name) { Faker::Name.first_name }
    let(:one_word_last_name) { Faker::Name.last_name.split.last }
    let(:note) do
      {
        'Id' => Faker::Number.number,
        'TituloNota' => Faker::Book.title,
        'ReseniaNota' => review,
        'FechaCreacionNota' => Faker::Time.backward.iso8601,
        'EmailAutor' => Faker::Internet.email,
        'NombreCompletoAutor' => "#{one_word_last_name} #{first_name}",
        'TituloLibro' => Faker::Book.title,
        'NombreAutorLibro' => Faker::Book.author,
        'GeneroLibro' => Faker::Book.genre,
        'Contenido' => Faker::Lorem.paragraph
      }
    end

    it 'maps the note title, creation date and content' do
      expect(mapped_note.slice(:title, :created_at, :content)).to eq(
        title: note['TituloNota'], created_at: note['FechaCreacionNota'], content: note['Contenido']
      )
    end

    it 'maps the author as the user, with the last name first in the full name' do
      expect(mapped_note[:user]).to eq(
        email: note['EmailAutor'], first_name: first_name, last_name: one_word_last_name
      )
    end

    it 'maps the note book' do
      expect(mapped_note[:book]).to eq(
        title: note['TituloLibro'], author: note['NombreAutorLibro'], genre: note['GeneroLibro']
      )
    end

    context 'when the note is a review' do
      let(:review) { true }

      it 'maps the type as review' do
        expect(mapped_note[:type]).to eq('review')
      end
    end

    context 'when the note is not a review' do
      let(:review) { false }

      it 'maps the type as critique' do
        expect(mapped_note[:type]).to eq('critique')
      end
    end
  end
end
