"""
****************************************************************************************************
:copyright (c) 2019-2020 URBANopt, Alliance for Sustainable Energy, LLC, and other contributors.

All rights reserved.

Redistribution and use in source and binary forms, with or without modification, are permitted
provided that the following conditions are met:

Redistributions of source code must retain the above copyright notice, this list of conditions
and the following disclaimer.

Redistributions in binary form must reproduce the above copyright notice, this list of conditions
and the following disclaimer in the documentation and/or other materials provided with the
distribution.

Neither the name of the copyright holder nor the names of its contributors may be used to endorse
or promote products derived from this software without specific prior written permission.

THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR
IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND
FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR
CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE,
DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER
IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT
OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
****************************************************************************************************
"""
from collections import defaultdict


class CouplingGraph:
    """Manages coupling relationships"""

    def __init__(self, couplings):
        if len(couplings) == 0:
            raise Exception('At least one coupling must be provided')
        self._couplings = couplings

        self._models_by_id = {}
        for coupling in self._couplings:
            a, b = coupling._model_a, coupling._model_b
            self._models_by_id[a.id] = a
            self._models_by_id[b.id] = b

        self._couplings_by_model_id = defaultdict(list)
        for coupling in self._couplings:
            a, b = coupling._model_a, coupling._model_b
            self._couplings_by_model_id[a.id].append(coupling)
            self._couplings_by_model_id[b.id].append(coupling)

    @property
    def couplings(self):
        return [coupling for coupling in self._couplings]

    @property
    def models(self):
        return [model for _, model in self._models_by_id.items()]

    def couplings_by_type(self, model):
        """Returns the model's associated couplings keyed by the types of the
        _other_ model involved

        For example if given model is ets, and its coupled to a load and network,
        the result would be:
        {
           'load_coupling': <load coupling>,
           'network_coupling': <network coupling>,
        }

        :param model: Model
        :return: dict
        """
        associated_couplings = self._couplings_by_model_id[model.id]

        directional_couplings = {}
        for coupling in associated_couplings:
            other_model = coupling.get_other_model(model)
            coupling_type = f'{other_model.simple_gmt_type}_coupling'
            directional_couplings[coupling_type] = coupling.to_dict()

        return directional_couplings