class Bed < ApplicationRecord
  belongs_to :bedroom
  BED_TYPES = {
    BED_SINGLE: 1,
    BED_DOUBLE: 2,
    BED_QUEEN: 2,
    BED_KING: 2,
    BED_BUNK: 2,
    BED_MURPHY: 1,
    BED_SOFA: 2,
    BED_COUCH: 1,
    BED_CHILD: 1,
    BED_CRIB: 1
  }
end
