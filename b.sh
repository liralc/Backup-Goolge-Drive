import React, { useState, useEffect } from 'react';
import { useThemeStore } from '../store/themeStore';
import { X } from 'lucide-react';
import { IFilterIP, IFilterIPList } from './IpFilterDialog';
import { Device } from '@/types/data';
import { api } from '@/api/mockApi';

type DeviceFilterProps = {
  isOpen: boolean;
  onClose: () => void;
  onFilterDevice: (filters: IFilterIPList) => void;
  className: string
}

export const DeviceFilterDialog: React.FC<DeviceFilterProps> = ({ isOpen, onClose, onFilterDevice }) => {
  const [ipInput, setIpInput] = useState({ ip: '', isSourceIp: true });
  const [error, setError] = useState('');
  const { isDarkMode } = useThemeStore();

  // Estado para lista de devices e devices selecionados
  const [devices, setDevices] = useState<Device[]>([]);
  const [selectedDevices, setSelectedDevices] = useState<string[]>([]); // array de IDs

  // Estado para loading dos devices
  const [loadingDevices, setLoadingDevices] = useState(false);

  // Buscar devices ao abrir o dialog
  useEffect(() => {
    if (isOpen) {
      setLoadingDevices(true);
      api.getListDevices().then((list) => {
        if (Array.isArray(list)) {
          setDevices(list);
        } else {
          setDevices([]);
        }
        setLoadingDevices(false);
      });
      setSelectedDevices([]); // limpa seleção ao abrir
      setIpInput({ ip: '', isSourceIp: true }); // limpa IP ao abrir
    }
  }, [isOpen]);

  if (!isOpen) return null;

  const handleSubmit = (e: React.FormEvent) => {
    e.preventDefault();
    if (ipInput.ip === '') {
      setError('Digite pelo menos um IP');
      return;
    }

    if (selectedDevices.length === 0) {
      setError('Selecione pelo menos um device');
      return;
    }
    setError('');
    // Envia devices como array de string (nomes)
    onFilterDevice({ ips: [ipInput], devices: selectedDevices } as any);
    onClose();
  };

  const handleIpChange = (value: string) => {
    setIpInput(prev => ({ ...prev, ip: value }));
  };

  const handleSourceIpChange = (checked: boolean) => {
    setIpInput(prev => ({ ...prev, isSourceIp: checked }));
  };

  // Handler para seleção de devices
  const handleDeviceSelect = (deviceName: string, checked: boolean) => {
    setSelectedDevices(prev =>
      checked ? [...prev, deviceName] : prev.filter(name => name !== deviceName)
    );
  };

  return (
    <div className="fixed inset-0 bg-black bg-opacity-50 flex items-center justify-center z-50">
      <div className={`${isDarkMode ? 'bg-gray-800' : 'bg-white'} rounded-lg p-6 w-[700px] relative`}>
        <button
          onClick={onClose}
          className={`absolute top-4 right-4 ${
            isDarkMode ? 'text-gray-400 hover:text-white' : 'text-gray-600 hover:text-gray-900'
          }`}
        >
          <X className="w-5 h-5" />
        </button>
        <h2 className={`text-xl font-bold mb-4 ${isDarkMode ? 'text-white' : 'text-gray-900'}`}>
         Buscar por IP e Device
        </h2>
        <form onSubmit={handleSubmit}>
          <div className="space-y-4">
            <div className="flex items-center gap-4">
              <div className="flex-1">
                <label className={`block text-sm font-medium mb-1 ${
                  isDarkMode ? 'text-gray-300' : 'text-gray-700'
                }`}>
                  IP
                </label>
                <input
                  type="text"
                  value={ipInput.ip}
                  onChange={(e) => handleIpChange(e.target.value)}
                  placeholder="Ex: 192.168.1.1"
                  className={`w-full p-2 border rounded focus:outline-none focus:ring-2 focus:ring-blue-500 ${
                    isDarkMode ? 'bg-gray-700 border-gray-600 text-white' : 'bg-white border-gray-300'
                  }`}
                />
              </div>
              <div className="flex items-center mt-6">
                <label className="flex items-center gap-2">
                  <input
                    type="checkbox"
                    checked={ipInput.isSourceIp}
                    onChange={(e) => handleSourceIpChange(e.target.checked)}
                    className={`rounded ${
                      isDarkMode ? 'bg-gray-700 border-gray-600' : 'bg-white border-gray-300'
                    } text-blue-600`}
                  />
                  <span className={`text-sm ${isDarkMode ? 'text-gray-300' : 'text-gray-700'}`}>
                    IP de Origem
                  </span>
                </label>
              </div>
            </div>
          </div>
          {/* Seletor de devices */}
          <div className="mt-6">
            <label className={`block text-sm font-medium mb-2 ${isDarkMode ? 'text-gray-300' : 'text-gray-700'}`}>
              Selecione os Devices
            </label>
            <div className="max-h-48 overflow-y-auto border rounded-lg p-3 flex flex-col gap-2 bg-gradient-to-br from-blue-50 to-blue-100 dark:from-gray-700 dark:to-gray-800 shadow-inner">
              {loadingDevices ? (
                <div className="flex items-center justify-center py-6">
                  <svg className="animate-spin h-6 w-6 text-blue-600 dark:text-blue-300 mr-2" viewBox="0 0 24 24">
                    <circle className="opacity-25" cx="12" cy="12" r="10" stroke="currentColor" strokeWidth="4" fill="none" />
                    <path className="opacity-75" fill="currentColor" d="M4 12a8 8 0 018-8v4l3-3-3-3v4a8 8 0 00-8 8h4z" />
                  </svg>
                  <span className={`text-base ${isDarkMode ? 'text-gray-200' : 'text-blue-700'}`}>Carregando devices...</span>
                </div>
              ) : devices.length === 0 ? (
                <span className="text-gray-400 text-sm">Nenhum device encontrado.</span>
              ) : (
                <div className="grid grid-cols-1 sm:grid-cols-2 gap-2">
                  {devices.map(device => (
                    <label
                      key={device.device}
                      className={`flex items-center gap-3 px-3 py-2 rounded-lg cursor-pointer transition border border-transparent hover:border-blue-400 dark:hover:border-blue-300 ${selectedDevices.includes(device.device) ? (isDarkMode ? 'bg-blue-900/40 border-blue-400' : 'bg-blue-200/60 border-blue-500') : (isDarkMode ? 'hover:bg-gray-700/60' : 'hover:bg-blue-50')}`}
                    >
                      <input
                        type="checkbox"
                        checked={selectedDevices.includes(device.device)}
                        onChange={e => handleDeviceSelect(device.device, e.target.checked)}
                        className="accent-blue-600 w-5 h-5 rounded focus:ring-2 focus:ring-blue-400 border-gray-300 dark:border-gray-600"
                      />
                      <span className={`font-medium text-sm ${isDarkMode ? 'text-gray-100' : 'text-blue-900'}`}>{device.device}</span>
                      <span className={`ml-auto text-xs px-2 py-0.5 rounded-full ${isDarkMode ? 'bg-blue-950 text-blue-200' : 'bg-blue-100 text-blue-700'}`}>Seq: {device.sequence}</span>
                    </label>
                  ))}
                </div>
              )}
            </div>
          </div>
          {error && <p className="text-red-500 text-sm mt-2">{error}</p>}
          <button
            type="submit"
            className="w-full bg-blue-600 text-white py-2 px-4 rounded hover:bg-blue-700 transition-colors mt-6"
          >
            Buscar FlowSpecs
          </button>
        </form>
      </div>
    </div>
  );
}